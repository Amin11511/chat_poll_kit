import 'package:flutter/material.dart';

import '../../theme/poll_theme.dart';

class PollError extends StatelessWidget {
  final String message;
  final PollTheme theme;
  final VoidCallback? onRetry;

  const PollError({
    super.key,
    required this.message,
    required this.theme,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: theme.containerPadding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: theme.containerBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.errorColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.optionTextStyle?.copyWith(
              color: theme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: theme.progressBarColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
