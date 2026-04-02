import 'package:flutter/material.dart';

import 'poll_theme_defaults.dart';

class PollTheme extends ThemeExtension<PollTheme> {
  final Color backgroundColor;
  final Color questionColor;
  final Color optionTextColor;
  final Color optionBackgroundColor;
  final Color optionSelectedColor;
  final Color progressBarColor;
  final Color progressBarBackgroundColor;
  final Color percentageColor;
  final Color checkIconColor;
  final Color footerTextColor;
  final Color countdownColor;
  final Color errorColor;

  final TextStyle? questionTextStyle;
  final TextStyle? optionTextStyle;
  final TextStyle? percentageTextStyle;
  final TextStyle? footerTextStyle;
  final TextStyle? countdownTextStyle;

  final BorderRadius optionBorderRadius;
  final BorderRadius containerBorderRadius;
  final EdgeInsetsGeometry containerPadding;
  final EdgeInsetsGeometry optionPadding;

  final Duration animationDuration;
  final Curve animationCurve;

  final double progressBarHeight;
  final double optionSpacing;

  const PollTheme({
    required this.backgroundColor,
    required this.questionColor,
    required this.optionTextColor,
    required this.optionBackgroundColor,
    required this.optionSelectedColor,
    required this.progressBarColor,
    required this.progressBarBackgroundColor,
    required this.percentageColor,
    required this.checkIconColor,
    required this.footerTextColor,
    required this.countdownColor,
    required this.errorColor,
    this.questionTextStyle,
    this.optionTextStyle,
    this.percentageTextStyle,
    this.footerTextStyle,
    this.countdownTextStyle,
    required this.optionBorderRadius,
    required this.containerBorderRadius,
    required this.containerPadding,
    required this.optionPadding,
    required this.animationDuration,
    required this.animationCurve,
    required this.progressBarHeight,
    required this.optionSpacing,
  });

  factory PollTheme.light() => PollThemeDefaults.light();
  factory PollTheme.dark() => PollThemeDefaults.dark();

  @override
  PollTheme copyWith({
    Color? backgroundColor,
    Color? questionColor,
    Color? optionTextColor,
    Color? optionBackgroundColor,
    Color? optionSelectedColor,
    Color? progressBarColor,
    Color? progressBarBackgroundColor,
    Color? percentageColor,
    Color? checkIconColor,
    Color? footerTextColor,
    Color? countdownColor,
    Color? errorColor,
    TextStyle? questionTextStyle,
    TextStyle? optionTextStyle,
    TextStyle? percentageTextStyle,
    TextStyle? footerTextStyle,
    TextStyle? countdownTextStyle,
    BorderRadius? optionBorderRadius,
    BorderRadius? containerBorderRadius,
    EdgeInsetsGeometry? containerPadding,
    EdgeInsetsGeometry? optionPadding,
    Duration? animationDuration,
    Curve? animationCurve,
    double? progressBarHeight,
    double? optionSpacing,
  }) {
    return PollTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      questionColor: questionColor ?? this.questionColor,
      optionTextColor: optionTextColor ?? this.optionTextColor,
      optionBackgroundColor:
          optionBackgroundColor ?? this.optionBackgroundColor,
      optionSelectedColor: optionSelectedColor ?? this.optionSelectedColor,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      progressBarBackgroundColor:
          progressBarBackgroundColor ?? this.progressBarBackgroundColor,
      percentageColor: percentageColor ?? this.percentageColor,
      checkIconColor: checkIconColor ?? this.checkIconColor,
      footerTextColor: footerTextColor ?? this.footerTextColor,
      countdownColor: countdownColor ?? this.countdownColor,
      errorColor: errorColor ?? this.errorColor,
      questionTextStyle: questionTextStyle ?? this.questionTextStyle,
      optionTextStyle: optionTextStyle ?? this.optionTextStyle,
      percentageTextStyle: percentageTextStyle ?? this.percentageTextStyle,
      footerTextStyle: footerTextStyle ?? this.footerTextStyle,
      countdownTextStyle: countdownTextStyle ?? this.countdownTextStyle,
      optionBorderRadius: optionBorderRadius ?? this.optionBorderRadius,
      containerBorderRadius:
          containerBorderRadius ?? this.containerBorderRadius,
      containerPadding: containerPadding ?? this.containerPadding,
      optionPadding: optionPadding ?? this.optionPadding,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      progressBarHeight: progressBarHeight ?? this.progressBarHeight,
      optionSpacing: optionSpacing ?? this.optionSpacing,
    );
  }

  @override
  PollTheme lerp(ThemeExtension<PollTheme>? other, double t) {
    if (other is! PollTheme) return this;
    return PollTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      questionColor: Color.lerp(questionColor, other.questionColor, t)!,
      optionTextColor: Color.lerp(optionTextColor, other.optionTextColor, t)!,
      optionBackgroundColor:
          Color.lerp(optionBackgroundColor, other.optionBackgroundColor, t)!,
      optionSelectedColor:
          Color.lerp(optionSelectedColor, other.optionSelectedColor, t)!,
      progressBarColor:
          Color.lerp(progressBarColor, other.progressBarColor, t)!,
      progressBarBackgroundColor: Color.lerp(
          progressBarBackgroundColor, other.progressBarBackgroundColor, t)!,
      percentageColor: Color.lerp(percentageColor, other.percentageColor, t)!,
      checkIconColor: Color.lerp(checkIconColor, other.checkIconColor, t)!,
      footerTextColor: Color.lerp(footerTextColor, other.footerTextColor, t)!,
      countdownColor: Color.lerp(countdownColor, other.countdownColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      questionTextStyle:
          TextStyle.lerp(questionTextStyle, other.questionTextStyle, t),
      optionTextStyle:
          TextStyle.lerp(optionTextStyle, other.optionTextStyle, t),
      percentageTextStyle:
          TextStyle.lerp(percentageTextStyle, other.percentageTextStyle, t),
      footerTextStyle:
          TextStyle.lerp(footerTextStyle, other.footerTextStyle, t),
      countdownTextStyle:
          TextStyle.lerp(countdownTextStyle, other.countdownTextStyle, t),
      optionBorderRadius:
          BorderRadius.lerp(optionBorderRadius, other.optionBorderRadius, t)!,
      containerBorderRadius: BorderRadius.lerp(
          containerBorderRadius, other.containerBorderRadius, t)!,
      containerPadding:
          EdgeInsetsGeometry.lerp(containerPadding, other.containerPadding, t)!,
      optionPadding:
          EdgeInsetsGeometry.lerp(optionPadding, other.optionPadding, t)!,
      animationDuration: other.animationDuration,
      animationCurve: other.animationCurve,
      progressBarHeight:
          lerpDouble(progressBarHeight, other.progressBarHeight, t)!,
      optionSpacing: lerpDouble(optionSpacing, other.optionSpacing, t)!,
    );
  }

  static double? lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}
