import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/poll_model.dart';
import '../models/poll_option.dart';
import '../models/vote_model.dart';
import 'poll_data_source.dart';

class FirebasePollAdapter implements PollDataSource {
  final FirebaseFirestore _firestore;
  final String pollsCollection;
  final String votesCollection;

  FirebasePollAdapter({
    FirebaseFirestore? firestore,
    this.pollsCollection = 'polls',
    this.votesCollection = 'votes',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _pollsRef => _firestore.collection(pollsCollection);
  CollectionReference get _votesRef => _firestore.collection(votesCollection);

  @override
  Future<PollModel> getPoll(String pollId) async {
    final doc = await _pollsRef.doc(pollId).get();
    if (!doc.exists) {
      throw Exception('Poll not found: $pollId');
    }
    final data = doc.data()! as Map<String, dynamic>;
    return _pollFromFirestore(pollId, data);
  }

  @override
  Stream<PollModel> watchPoll(String pollId) {
    return _pollsRef.doc(pollId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Poll not found: $pollId');
      }
      final data = snapshot.data()! as Map<String, dynamic>;
      return _pollFromFirestore(pollId, data);
    });
  }

  @override
  Future<void> submitVote({
    required String pollId,
    required String userId,
    required List<String> optionIds,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final pollDoc = await transaction.get(_pollsRef.doc(pollId));
      if (!pollDoc.exists) {
        throw Exception('Poll not found: $pollId');
      }

      final data = pollDoc.data()! as Map<String, dynamic>;
      final options = List<Map<String, dynamic>>.from(data['options'] as List);

      for (final optionId in optionIds) {
        final index = options.indexWhere((o) => o['id'] == optionId);
        if (index == -1) {
          throw Exception('Option not found: $optionId');
        }
        options[index] = {
          ...options[index],
          'votes': ((options[index]['votes'] as num?)?.toInt() ?? 0) + 1,
        };
      }

      transaction.update(_pollsRef.doc(pollId), {'options': options});

      final voteId = const Uuid().v4();
      transaction.set(_votesRef.doc(voteId), {
        'id': voteId,
        'pollId': pollId,
        'userId': userId,
        'optionIds': optionIds,
        'votedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<bool> hasUserVoted({
    required String pollId,
    required String userId,
  }) async {
    final query = await _votesRef
        .where('pollId', isEqualTo: pollId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  @override
  Future<List<VoteModel>> getUserVotes({
    required String pollId,
    required String userId,
  }) async {
    final query = await _votesRef
        .where('pollId', isEqualTo: pollId)
        .where('userId', isEqualTo: userId)
        .get();
    return query.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return VoteModel(
        id: data['id'] as String,
        pollId: data['pollId'] as String,
        userId: data['userId'] as String,
        optionIds: List<String>.from(data['optionIds'] as List),
        votedAt: (data['votedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  PollModel _pollFromFirestore(String id, Map<String, dynamic> data) {
    return PollModel(
      id: id,
      question: data['question'] as String,
      options: (data['options'] as List)
          .map((o) => PollOption.fromJson(Map<String, dynamic>.from(o as Map)))
          .toList(),
      allowMultipleChoices: data['allowMultipleChoices'] as bool? ?? false,
      allowVoteChange: data['allowVoteChange'] as bool? ?? false,
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
