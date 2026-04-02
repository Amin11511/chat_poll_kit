import 'package:flutter/material.dart';

import '../../models/poll_model.dart';
import '../../theme/poll_theme.dart';
import '../poll_footer.dart';
import '../poll_option_tile.dart';

class PollExpired extends StatelessWidget {
  final PollModel poll;
  final Set<String> selectedOptionIds;
  final PollTheme theme;

  const PollExpired({
    super.key,
    required this.poll,
    required this.selectedOptionIds,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_clock,
              size: 16,
              color: theme.countdownColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Poll ended',
              style: theme.countdownTextStyle?.copyWith(
                color: theme.countdownColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          poll.question,
          style: theme.questionTextStyle?.copyWith(
            color: theme.questionColor,
          ),
        ),
        const SizedBox(height: 12),
        ...poll.options.map(
          (option) => Padding(
            padding: EdgeInsets.only(bottom: theme.optionSpacing),
            child: PollOptionTile(
              option: option,
              totalVotes: poll.totalVotes,
              isSelected: selectedOptionIds.contains(option.id),
              showResults: true,
              enabled: false,
              theme: theme,
            ),
          ),
        ),
        const SizedBox(height: 4),
        PollFooter(
          totalVotes: poll.totalVotes,
          hasVoted: selectedOptionIds.isNotEmpty,
          isExpired: true,
          theme: theme,
        ),
      ],
    );
  }
}
