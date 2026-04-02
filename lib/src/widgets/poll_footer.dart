import 'package:flutter/material.dart';

import '../theme/poll_theme.dart';

class PollFooter extends StatelessWidget {
  final int totalVotes;
  final bool hasVoted;
  final bool isExpired;
  final PollTheme theme;
  final VoidCallback? onVote;

  const PollFooter({
    super.key,
    required this.totalVotes,
    required this.hasVoted,
    required this.isExpired,
    required this.theme,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final votesText = totalVotes == 1 ? '1 vote' : '$totalVotes votes';
    final statusText = isExpired
        ? 'Final results'
        : hasVoted
            ? 'You voted'
            : '';

    return Row(
      children: [
        Text(
          votesText,
          style: theme.footerTextStyle?.copyWith(
            color: theme.footerTextColor,
          ),
        ),
        if (statusText.isNotEmpty) ...[
          Text(
            ' · $statusText',
            style: theme.footerTextStyle?.copyWith(
              color: theme.footerTextColor,
            ),
          ),
        ],
        const Spacer(),
        if (!hasVoted && !isExpired && onVote != null)
          TextButton(
            onPressed: onVote,
            style: TextButton.styleFrom(
              foregroundColor: theme.progressBarColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Vote'),
          ),
      ],
    );
  }
}
