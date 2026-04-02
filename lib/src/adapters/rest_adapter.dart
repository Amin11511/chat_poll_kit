import 'dart:async';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../models/poll_model.dart';
import '../models/vote_model.dart';
import 'poll_data_source.dart';

class RestPollAdapter implements PollDataSource {
  final Dio _dio;
  final String baseEndpoint;
  final Duration pollingInterval;

  RestPollAdapter({
    required Dio dio,
    this.baseEndpoint = '/polls',
    this.pollingInterval = const Duration(seconds: 3),
  }) : _dio = dio;

  @override
  Future<PollModel> getPoll(String pollId) async {
    final response = await _dio.get('$baseEndpoint/$pollId');
    return PollModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Stream<PollModel> watchPoll(String pollId) {
    late StreamController<PollModel> controller;
    Timer? timer;

    controller = StreamController<PollModel>(
      onListen: () {
        Future<void> fetch() async {
          try {
            final poll = await getPoll(pollId);
            if (!controller.isClosed) {
              controller.add(poll);
            }
          } catch (e) {
            if (!controller.isClosed) {
              controller.addError(e);
            }
          }
        }

        fetch();
        timer = Timer.periodic(pollingInterval, (_) => fetch());
      },
      onCancel: () {
        timer?.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }

  @override
  Future<void> submitVote({
    required String pollId,
    required String userId,
    required List<String> optionIds,
  }) async {
    await _dio.post(
      '$baseEndpoint/$pollId/votes',
      data: {
        'id': const Uuid().v4(),
        'pollId': pollId,
        'userId': userId,
        'optionIds': optionIds,
        'votedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<bool> hasUserVoted({
    required String pollId,
    required String userId,
  }) async {
    final response = await _dio.get(
      '$baseEndpoint/$pollId/votes',
      queryParameters: {'userId': userId},
    );
    final votes = response.data as List;
    return votes.isNotEmpty;
  }

  @override
  Future<List<VoteModel>> getUserVotes({
    required String pollId,
    required String userId,
  }) async {
    final response = await _dio.get(
      '$baseEndpoint/$pollId/votes',
      queryParameters: {'userId': userId},
    );
    final votes = response.data as List;
    return votes
        .map((v) => VoteModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }
}
