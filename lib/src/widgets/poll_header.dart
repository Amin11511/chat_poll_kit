import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/poll_theme.dart';
import '../utils/expiry_timer.dart';

class PollHeader extends StatefulWidget {
  final String question;
  final DateTime? expiresAt;
  final PollTheme theme;

  const PollHeader({
    super.key,
    required this.question,
    this.expiresAt,
    required this.theme,
  });

  @override
  State<PollHeader> createState() => _PollHeaderState();
}

class _PollHeaderState extends State<PollHeader> {
  StreamSubscription<Duration>? _timerSubscription;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(PollHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) {
      _timerSubscription?.cancel();
      _startCountdown();
    }
  }

  void _startCountdown() {
    if (widget.expiresAt == null) return;

    _timerSubscription = ExpiryTimer.countdown(widget.expiresAt!).listen(
      (remaining) {
        if (mounted) {
          setState(() {
            _countdownText = ExpiryTimer.formatDuration(remaining);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: widget.theme.questionTextStyle?.copyWith(
            color: widget.theme.questionColor,
          ),
        ),
        if (_countdownText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: widget.theme.countdownColor,
              ),
              const SizedBox(width: 4),
              Text(
                _countdownText,
                style: widget.theme.countdownTextStyle?.copyWith(
                  color: widget.theme.countdownColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
