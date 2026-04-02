import 'package:flutter/material.dart';

import '../theme/poll_theme.dart';

class PollProgressBar extends StatelessWidget {
  final double percentage;
  final PollTheme theme;

  const PollProgressBar({
    super.key,
    required this.percentage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (percentage / 100).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: fraction),
      duration: theme.animationDuration,
      curve: theme.animationCurve,
      builder: (context, value, _) {
        return Container(
          height: theme.progressBarHeight,
          decoration: BoxDecoration(
            color: theme.progressBarBackgroundColor,
            borderRadius: BorderRadius.circular(theme.progressBarHeight / 2),
          ),
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: theme.progressBarColor,
                borderRadius:
                    BorderRadius.circular(theme.progressBarHeight / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
