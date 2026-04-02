import '../models/poll_model.dart';
import '../models/vote_model.dart';

abstract class PollDataSource {
  Future<PollModel> getPoll(String pollId);

  Stream<PollModel> watchPoll(String pollId);

  Future<void> submitVote({
    required String pollId,
    required String userId,
    required List<String> optionIds,
  });

  Future<bool> hasUserVoted({
    required String pollId,
    required String userId,
  });

  Future<List<VoteModel>> getUserVotes({
    required String pollId,
    required String userId,
  });
}
