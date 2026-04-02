import 'dart:async';

import 'package:chat_poll_kit/chat_poll_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDataSource extends Mock implements PollDataSource {}

void main() {
  late MockDataSource dataSource;
  late PollController controller;
  late StreamController<PollModel> pollStreamController;

  final testPoll = PollModel(
    id: 'poll_1',
    question: 'Test question?',
    options: const [
      PollOption(id: 'a', text: 'Option A', votes: 5),
      PollOption(id: 'b', text: 'Option B', votes: 3),
    ],
    createdAt: DateTime.now(),
  );

  setUp(() {
    dataSource = MockDataSource();
    pollStreamController = StreamController<PollModel>();
    controller = PollController(
      dataSource: dataSource,
      pollId: 'poll_1',
      userId: 'user_1',
    );
  });

  tearDown(() {
    controller.dispose();
    pollStreamController.close();
  });

  group('PollController', () {
    test('initialize sets loading then receives poll data', () async {
      when(() => dataSource.hasUserVoted(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => false);
      when(() => dataSource.getUserVotes(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => []);
      when(() => dataSource.watchPoll('poll_1'))
          .thenAnswer((_) => pollStreamController.stream);

      expect(controller.isLoading, isTrue);

      await controller.initialize();

      // Still loading until stream emits
      expect(controller.poll, isNull);

      // Emit poll from stream
      pollStreamController.add(testPoll);
      await Future<void>.delayed(Duration.zero);

      expect(controller.isLoading, isFalse);
      expect(controller.poll, isNotNull);
      expect(controller.poll!.question, 'Test question?');
      expect(controller.hasVoted, isFalse);
    });

    test('initialize detects existing vote', () async {
      when(() => dataSource.hasUserVoted(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => true);
      when(() => dataSource.getUserVotes(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => [
            VoteModel(
              id: 'v1',
              pollId: 'poll_1',
              userId: 'user_1',
              optionIds: ['a'],
              votedAt: DateTime.now(),
            ),
          ]);
      when(() => dataSource.watchPoll('poll_1'))
          .thenAnswer((_) => pollStreamController.stream);

      await controller.initialize();
      pollStreamController.add(testPoll);
      await Future<void>.delayed(Duration.zero);

      expect(controller.hasVoted, isTrue);
      expect(controller.selectedOptionIds, contains('a'));
    });

    test('toggleOption selects and deselects', () async {
      when(() => dataSource.hasUserVoted(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => false);
      when(() => dataSource.getUserVotes(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => []);
      when(() => dataSource.watchPoll('poll_1'))
          .thenAnswer((_) => pollStreamController.stream);

      await controller.initialize();
      pollStreamController.add(testPoll);
      await Future<void>.delayed(Duration.zero);

      controller.toggleOption('a');
      expect(controller.selectedOptionIds, {'a'});

      // Single choice: selecting 'b' should replace 'a'
      controller.toggleOption('b');
      expect(controller.selectedOptionIds, {'b'});
    });

    test('vote submits successfully with optimistic update', () async {
      when(() => dataSource.hasUserVoted(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => false);
      when(() => dataSource.getUserVotes(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => []);
      when(() => dataSource.watchPoll('poll_1'))
          .thenAnswer((_) => pollStreamController.stream);
      when(() => dataSource.submitVote(
            pollId: 'poll_1',
            userId: 'user_1',
            optionIds: ['a'],
          )).thenAnswer((_) async {});

      await controller.initialize();
      pollStreamController.add(testPoll);
      await Future<void>.delayed(Duration.zero);

      controller.toggleOption('a');
      await controller.vote();

      expect(controller.hasVoted, isTrue);
      expect(controller.errorMessage, isNull);
      // Optimistic: option A votes should be 6
      final optionA =
          controller.poll!.options.firstWhere((o) => o.id == 'a');
      expect(optionA.votes, 6);
    });

    test('vote reverts on failure', () async {
      when(() => dataSource.hasUserVoted(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => false);
      when(() => dataSource.getUserVotes(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => []);
      when(() => dataSource.watchPoll('poll_1'))
          .thenAnswer((_) => pollStreamController.stream);
      when(() => dataSource.submitVote(
            pollId: 'poll_1',
            userId: 'user_1',
            optionIds: ['a'],
          )).thenThrow(Exception('Network error'));

      await controller.initialize();
      pollStreamController.add(testPoll);
      await Future<void>.delayed(Duration.zero);

      controller.toggleOption('a');
      await controller.vote();

      expect(controller.hasVoted, isFalse);
      expect(controller.errorMessage, isNotNull);
      // Reverted: option A votes should be back to 5
      final optionA =
          controller.poll!.options.firstWhere((o) => o.id == 'a');
      expect(optionA.votes, 5);
    });

    test('handles stream error', () async {
      when(() => dataSource.hasUserVoted(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => false);
      when(() => dataSource.getUserVotes(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => []);
      when(() => dataSource.watchPoll('poll_1'))
          .thenAnswer((_) => pollStreamController.stream);

      await controller.initialize();
      pollStreamController.addError(Exception('Stream failed'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.errorMessage, isNotNull);
      expect(controller.isLoading, isFalse);
    });

    test('expired poll detected via isExpired', () async {
      final expiredPoll = testPoll.copyWith(
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      when(() => dataSource.hasUserVoted(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => false);
      when(() => dataSource.getUserVotes(
            pollId: 'poll_1',
            userId: 'user_1',
          )).thenAnswer((_) async => []);
      when(() => dataSource.watchPoll('poll_1'))
          .thenAnswer((_) => pollStreamController.stream);

      await controller.initialize();
      pollStreamController.add(expiredPoll);
      await Future<void>.delayed(Duration.zero);

      expect(controller.isExpired, isTrue);
    });
  });
}
