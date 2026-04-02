import 'package:chat_poll_kit/chat_poll_kit.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebasePollAdapter adapter;

  final pollData = {
    'question': 'Test poll?',
    'options': [
      {'id': 'a', 'text': 'Option A', 'votes': 5},
      {'id': 'b', 'text': 'Option B', 'votes': 3},
    ],
    'allowMultipleChoices': false,
    'allowVoteChange': false,
    'createdAt': DateTime.now(),
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    adapter = FirebasePollAdapter(firestore: fakeFirestore);
  });

  group('FirebasePollAdapter', () {
    test('getPoll returns poll data', () async {
      await fakeFirestore.collection('polls').doc('p1').set(pollData);

      final poll = await adapter.getPoll('p1');
      expect(poll.id, 'p1');
      expect(poll.question, 'Test poll?');
      expect(poll.options.length, 2);
      expect(poll.options[0].votes, 5);
    });

    test('getPoll throws for non-existent poll', () async {
      expect(
        () => adapter.getPoll('nonexistent'),
        throwsA(isA<Exception>()),
      );
    });

    test('watchPoll emits poll updates', () async {
      await fakeFirestore.collection('polls').doc('p1').set(pollData);

      final stream = adapter.watchPoll('p1');
      final poll = await stream.first;

      expect(poll.question, 'Test poll?');
      expect(poll.options.length, 2);
    });

    test('submitVote increments option votes atomically', () async {
      await fakeFirestore.collection('polls').doc('p1').set(pollData);

      await adapter.submitVote(
        pollId: 'p1',
        userId: 'user_1',
        optionIds: ['a'],
      );

      final updatedDoc =
          await fakeFirestore.collection('polls').doc('p1').get();
      final options = updatedDoc.data()!['options'] as List;
      final optionA = options.firstWhere((o) => o['id'] == 'a');
      expect(optionA['votes'], 6);

      // Verify vote was recorded
      final votesSnap = await fakeFirestore
          .collection('votes')
          .where('pollId', isEqualTo: 'p1')
          .where('userId', isEqualTo: 'user_1')
          .get();
      expect(votesSnap.docs.length, 1);
    });

    test('hasUserVoted returns true after vote', () async {
      await fakeFirestore.collection('polls').doc('p1').set(pollData);

      expect(
        await adapter.hasUserVoted(pollId: 'p1', userId: 'user_1'),
        isFalse,
      );

      await adapter.submitVote(
        pollId: 'p1',
        userId: 'user_1',
        optionIds: ['b'],
      );

      expect(
        await adapter.hasUserVoted(pollId: 'p1', userId: 'user_1'),
        isTrue,
      );
    });

    test('getUserVotes returns all user votes', () async {
      await fakeFirestore.collection('polls').doc('p1').set(pollData);

      await adapter.submitVote(
        pollId: 'p1',
        userId: 'user_1',
        optionIds: ['a'],
      );

      final votes = await adapter.getUserVotes(
        pollId: 'p1',
        userId: 'user_1',
      );
      expect(votes.length, 1);
      expect(votes.first.optionIds, ['a']);
    });
  });
}
