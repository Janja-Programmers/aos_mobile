import 'package:flutter/material.dart';

/// Theme-aware color tokens for the app.
/// Add to ThemeData.extensions and read via: `context.appColors`.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.primary,
    required this.primaryHover,
    required this.surface,
    required this.surfaceBright,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.elevated,
    required this.border,
    required this.btnText,

    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  final Color primary;
  final Color primaryHover;
  final Color surface;
  final Color surfaceBright;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color elevated;
  final Color border;
  final Color btnText;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  static const light = AppColorTokens(
    primary: Color(0xFFC1121F),
    primaryHover: Color.fromARGB(255, 131, 30, 35),

    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF555555),
    textMuted: Color(0xFF8A8A8A),
    surface: Color.fromARGB(255, 213, 211, 211),
    surfaceBright: Color(0xFFFAFAFA),
    elevated: Color(0xFFF5F5F5),
    border: Color(0xFFE8E8E8),
    btnText: Color(0xFFFFFFFF),

    success: Color(0xFF2ECC71),
    warning: Color(0xFFF5A623),
    error: Color(0xFFFF4D4D),
    info: Color(0xFF4DA3FF),
  );

  static const dark = AppColorTokens(
    primary: Color(0xFFC1121F),
    primaryHover: Color(0xFF8E0E15),

    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF555555),
    textMuted: Color(0xFF8A8A8A),
    surface: Color(0xFFFAFAFA),
    surfaceBright: Color(0xFFFFFFFF),
    elevated: Color(0xFFF5F5F5),
    border: Color(0xFFE8E8E8),
    btnText: Color(0xFFFFFFFF),

    success: Color(0xFF2ECC71),
    warning: Color(0xFFF5A623),
    error: Color(0xFFFF4D4D),
    info: Color(0xFF4DA3FF),
  );

  @override
  AppColorTokens copyWith({
    Color? primary,
    Color? primaryHover,
    Color? surface,
    Color? surfaceBright,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? elevated,
    Color? border,
    Color? btnText,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColorTokens(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      surface: surface ?? this.surface,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      elevated: elevated ?? this.elevated,
      border: border ?? this.border,
      btnText: btnText ?? this.btnText,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryHover:
          Color.lerp(primaryHover, other.primaryHover, t) ?? primaryHover,

      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceBright:
          Color.lerp(surfaceBright, other.surfaceBright, t) ?? surfaceBright,
      elevated: Color.lerp(elevated, other.elevated, t) ?? elevated,
      border: Color.lerp(border, other.border, t) ?? border,
      btnText: Color.lerp(btnText, other.btnText, t) ?? btnText,

      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}
