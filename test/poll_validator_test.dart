import 'package:chat_poll_kit/chat_poll_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final basePoll = PollModel(
    id: 'poll_1',
    question: 'Test?',
    options: const [
      PollOption(id: 'a', text: 'A', votes: 5),
      PollOption(id: 'b', text: 'B', votes: 3),
    ],
    createdAt: DateTime.now(),
  );

  group('PollValidator', () {
    test('valid single-choice vote', () {
      final result = PollValidator.validate(
        poll: basePoll,
        selectedOptionIds: ['a'],
        hasAlreadyVoted: false,
      );
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('rejects empty option ids', () {
      final result = PollValidator.validate(
        poll: basePoll,
        selectedOptionIds: [],
        hasAlreadyVoted: false,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('at least one'));
    });

    test('rejects multiple choices on single-choice poll', () {
      final result = PollValidator.validate(
        poll: basePoll,
        selectedOptionIds: ['a', 'b'],
        hasAlreadyVoted: false,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('single choice'));
    });

    test('allows multiple choices when allowMultipleChoices is true', () {
      final multiPoll = basePoll.copyWith(allowMultipleChoices: true);
      final result = PollValidator.validate(
        poll: multiPoll,
        selectedOptionIds: ['a', 'b'],
        hasAlreadyVoted: false,
      );
      expect(result.isValid, isTrue);
    });

    test('rejects invalid option id', () {
      final result = PollValidator.validate(
        poll: basePoll,
        selectedOptionIds: ['nonexistent'],
        hasAlreadyVoted: false,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Invalid option'));
    });

    test('rejects duplicate vote when allowVoteChange is false', () {
      final result = PollValidator.validate(
        poll: basePoll,
        selectedOptionIds: ['a'],
        hasAlreadyVoted: true,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('already voted'));
    });

    test('allows duplicate vote when allowVoteChange is true', () {
      final poll = basePoll.copyWith(allowVoteChange: true);
      final result = PollValidator.validate(
        poll: poll,
        selectedOptionIds: ['a'],
        hasAlreadyVoted: true,
      );
      expect(result.isValid, isTrue);
    });

    test('rejects expired poll', () {
      final expired = basePoll.copyWith(
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      final result = PollValidator.validate(
        poll: expired,
        selectedOptionIds: ['a'],
        hasAlreadyVoted: false,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('expired'));
    });

    test('accepts non-expired poll with future expiry', () {
      final active = basePoll.copyWith(
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final result = PollValidator.validate(
        poll: active,
        selectedOptionIds: ['a'],
        hasAlreadyVoted: false,
      );
      expect(result.isValid, isTrue);
    });
  });
}
