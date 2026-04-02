import 'package:flutter/material.dart';

import 'poll_theme.dart';

class PollThemeDefaults {
  static PollTheme light() {
    return PollTheme(
      backgroundColor: Colors.white,
      questionColor: const Color(0xFF1A1A2E),
      optionTextColor: const Color(0xFF1A1A2E),
      optionBackgroundColor: const Color(0xFFF0F0F5),
      optionSelectedColor: const Color(0xFFE3F2FD),
      progressBarColor: const Color(0xFF2196F3),
      progressBarBackgroundColor: const Color(0xFFE0E0E0),
      percentageColor: const Color(0xFF616161),
      checkIconColor: const Color(0xFF2196F3),
      footerTextColor: const Color(0xFF9E9E9E),
      countdownColor: const Color(0xFFFF9800),
      errorColor: const Color(0xFFE53935),
      questionTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
      optionTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF1A1A2E),
      ),
      percentageTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF616161),
      ),
      footerTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFF9E9E9E),
      ),
      countdownTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFFFF9800),
      ),
      optionBorderRadius: BorderRadius.circular(8),
      containerBorderRadius: BorderRadius.circular(12),
      containerPadding: const EdgeInsets.all(16),
      optionPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      animationDuration: const Duration(milliseconds: 400),
      animationCurve: Curves.easeInOut,
      progressBarHeight: 6,
      optionSpacing: 8,
    );
  }

  static PollTheme dark() {
    return PollTheme(
      backgroundColor: const Color(0xFF1E1E2E),
      questionColor: const Color(0xFFE0E0E0),
      optionTextColor: const Color(0xFFE0E0E0),
      optionBackgroundColor: const Color(0xFF2A2A3E),
      optionSelectedColor: const Color(0xFF1A3A5C),
      progressBarColor: const Color(0xFF64B5F6),
      progressBarBackgroundColor: const Color(0xFF424242),
      percentageColor: const Color(0xFFBDBDBD),
      checkIconColor: const Color(0xFF64B5F6),
      footerTextColor: const Color(0xFF757575),
      countdownColor: const Color(0xFFFFB74D),
      errorColor: const Color(0xFFEF5350),
      questionTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      optionTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFE0E0E0),
      ),
      percentageTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFFBDBDBD),
      ),
      footerTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFF757575),
      ),
      countdownTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFFFFB74D),
      ),
      optionBorderRadius: BorderRadius.circular(8),
      containerBorderRadius: BorderRadius.circular(12),
      containerPadding: const EdgeInsets.all(16),
      optionPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      animationDuration: const Duration(milliseconds: 400),
      animationCurve: Curves.easeInOut,
      progressBarHeight: 6,
      optionSpacing: 8,
    );
  }
}
