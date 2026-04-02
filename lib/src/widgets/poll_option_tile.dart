import 'package:flutter/material.dart';

import '../models/poll_option.dart';
import '../theme/poll_theme.dart';
import 'poll_progress_bar.dart';

class PollOptionTile extends StatelessWidget {
  final PollOption option;
  final int totalVotes;
  final bool isSelected;
  final bool showResults;
  final bool enabled;
  final PollTheme theme;
  final VoidCallback? onTap;

  const PollOptionTile({
    super.key,
    required this.option,
    required this.totalVotes,
    required this.isSelected,
    required this.showResults,
    required this.enabled,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = option.percentage(totalVotes);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: theme.animationDuration,
        curve: theme.animationCurve,
        padding: theme.optionPadding,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.optionSelectedColor
              : theme.optionBackgroundColor,
          borderRadius: theme.optionBorderRadius,
          border: isSelected
              ? Border.all(color: theme.progressBarColor, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: theme.checkIconColor,
                    ),
                  ),
                Expanded(
                  child: Text(
                    option.text,
                    style: theme.optionTextStyle?.copyWith(
                      color: theme.optionTextColor,
                    ),
                  ),
                ),
                if (showResults)
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: theme.percentageTextStyle?.copyWith(
                      color: theme.percentageColor,
                    ),
                  ),
              ],
            ),
            if (showResults) ...[
              const SizedBox(height: 6),
              PollProgressBar(
                percentage: percentage,
                theme: theme,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
