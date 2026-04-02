import 'package:flutter/material.dart';

import '../../theme/poll_theme.dart';

class PollLoading extends StatelessWidget {
  final PollTheme theme;

  const PollLoading({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: theme.containerPadding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: theme.containerBorderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: theme.progressBarColor,
          ),
        ),
      ),
    );
  }
}
