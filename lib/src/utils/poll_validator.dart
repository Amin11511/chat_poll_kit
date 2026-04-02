import '../models/poll_model.dart';

class PollValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PollValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const PollValidationResult.invalid(String message)
      : isValid = false,
        errorMessage = message;
}

class PollValidator {
  static PollValidationResult validate({
    required PollModel poll,
    required List<String> selectedOptionIds,
    required bool hasAlreadyVoted,
  }) {
    if (poll.isExpired) {
      return const PollValidationResult.invalid('This poll has expired.');
    }

    if (selectedOptionIds.isEmpty) {
      return const PollValidationResult.invalid(
          'Please select at least one option.');
    }

    if (!poll.allowMultipleChoices && selectedOptionIds.length > 1) {
      return const PollValidationResult.invalid(
          'This poll only allows a single choice.');
    }

    final validIds = poll.options.map((o) => o.id).toSet();
    for (final id in selectedOptionIds) {
      if (!validIds.contains(id)) {
        return PollValidationResult.invalid('Invalid option: $id');
      }
    }

    if (hasAlreadyVoted && !poll.allowVoteChange) {
      return const PollValidationResult.invalid(
          'You have already voted on this poll.');
    }

    return const PollValidationResult.valid();
  }
}
