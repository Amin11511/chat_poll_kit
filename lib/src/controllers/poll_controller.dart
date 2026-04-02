import 'dart:async';

import 'package:flutter/foundation.dart';

import '../adapters/poll_data_source.dart';
import '../models/poll_model.dart';
import '../utils/poll_validator.dart';

class PollController extends ChangeNotifier {
  final PollDataSource dataSource;
  final String pollId;
  final String userId;

  PollModel? _poll;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasVoted = false;
  Set<String> _selectedOptionIds = {};
  StreamSubscription<PollModel>? _pollSubscription;

  PollController({
    required this.dataSource,
    required this.pollId,
    required this.userId,
  });

  PollModel? get poll => _poll;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasVoted => _hasVoted;
  Set<String> get selectedOptionIds => Set.unmodifiable(_selectedOptionIds);
  bool get isExpired => _poll?.isExpired ?? false;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hasVoted = await dataSource.hasUserVoted(
        pollId: pollId,
        userId: userId,
      );

      if (_hasVoted) {
        final votes = await dataSource.getUserVotes(
          pollId: pollId,
          userId: userId,
        );
        if (votes.isNotEmpty) {
          _selectedOptionIds = votes.last.optionIds.toSet();
        }
      }

      _pollSubscription = dataSource.watchPoll(pollId).listen(
        (poll) {
          _poll = poll;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (Object error) {
          _errorMessage = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleOption(String optionId) {
    if (_hasVoted && !(_poll?.allowVoteChange ?? false)) return;
    if (isExpired) return;

    if (_poll?.allowMultipleChoices ?? false) {
      final newSet = Set<String>.from(_selectedOptionIds);
      if (newSet.contains(optionId)) {
        newSet.remove(optionId);
      } else {
        newSet.add(optionId);
      }
      _selectedOptionIds = newSet;
    } else {
      _selectedOptionIds = {optionId};
    }
    notifyListeners();
  }

  Future<void> vote() async {
    if (_poll == null) return;

    final validation = PollValidator.validate(
      poll: _poll!,
      selectedOptionIds: _selectedOptionIds.toList(),
      hasAlreadyVoted: _hasVoted,
    );

    if (!validation.isValid) {
      _errorMessage = validation.errorMessage;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Optimistic update
      final optionIds = _selectedOptionIds.toList();
      _poll = _poll!.copyWith(
        options: _poll!.options.map((option) {
          if (optionIds.contains(option.id)) {
            return option.copyWith(votes: option.votes + 1);
          }
          return option;
        }).toList(),
      );
      _hasVoted = true;
      _isLoading = false;
      notifyListeners();

      await dataSource.submitVote(
        pollId: pollId,
        userId: userId,
        optionIds: optionIds,
      );
    } catch (e) {
      // Revert optimistic update
      _hasVoted = false;
      _poll = _poll!.copyWith(
        options: _poll!.options.map((option) {
          if (_selectedOptionIds.contains(option.id)) {
            return option.copyWith(votes: option.votes - 1);
          }
          return option;
        }).toList(),
      );
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollSubscription?.cancel();
    super.dispose();
  }
}
