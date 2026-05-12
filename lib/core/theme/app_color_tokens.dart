import 'package:flutter/material.dart';

/// Theme-aware color tokens for the app.
/// Add to ThemeData.extensions and read via: `context.appColors`.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.primary,
    required this.primaryHover,
    required this.primaryRedSoft,
    required this.surface,
    required this.surfaceBright,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.elevated,
    required this.border,
    required this.btnText,
    required this.chatCardColor,

    required this.success,
    required this.warning,
    required this.error,
    required this.info,

    required this.white,
    required this.black,
    required this.blue,
    required this.orange,
    required this.amber,
    required this.red,
  });

  final Color primary;
  final Color primaryHover;
  final Color primaryRedSoft;
  final Color surface;
  final Color surfaceBright;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color elevated;
  final Color border;
  final Color btnText;
  final Color chatCardColor;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  final Color white;
  final Color black;
  final Color blue;
  final Color orange;
  final Color amber;
  final Color red;

  static const light = AppColorTokens(
    primary: Color(0xFFC1121F),
    primaryHover: Color(0xFF8E0E15),
    primaryRedSoft: Color(0xFFC1121F),

    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF555555),
    textMuted: Color(0xFF8A8A8A),
    surface: Color(0xFFFAFAFA),
    surfaceBright: Color(0xFFFFFFFF),
    elevated: Color(0xFFFFFFFF),
    border: Color(0xFFE8E8E8),
    btnText: Color(0xFFFFFFFF),
    chatCardColor: Color.fromARGB(199, 40, 13, 93),

    success: Color(0xFF2ECC71),
    warning: Color(0xFFF5A623),
    error: Color(0xFFFF4D4D),
    info: Color(0xFF4DA3FF),

    white: Colors.white,
    black: Colors.black,
    blue: Colors.blue,
    orange: Colors.orange,
    amber: Colors.amber,
    red: Colors.red,
  );

  static const dark = AppColorTokens(
    primary: Color(0xFFC1121F),
    primaryHover: Color(0xFF8E0E15),
    primaryRedSoft: Color(0xFFC1121F),

    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB3B3B3),
    textMuted: Color(0xFF8A8A8A),
    surface: Color(0xFF080808),
    surfaceBright: Color(0xFF121212),
    elevated: Color(0xFF161616),
    border: Color(0xFF2A2A2A),
    btnText: Color(0xFFFFFFFF),
    chatCardColor: Color.fromARGB(199, 40, 13, 93),

    success: Color(0xFF2ECC71),
    warning: Color(0xFFF5A623),
    error: Color(0xFFFF4D4D),
    info: Color(0xFF4DA3FF),

    white: Colors.white,
    black: Colors.black,
    blue: Colors.blue,
    orange: Colors.orange,
    amber: Colors.amber,
    red: Colors.red,
  );

  @override
  AppColorTokens copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryRedSoft,
    Color? surface,
    Color? surfaceBright,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? elevated,
    Color? border,
    Color? btnText,
    Color? chatCardColor,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? white,
    Color? black,
    Color? blue,
    Color? orange,
    Color? amber,
    Color? red,
  }) {
    return AppColorTokens(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryRedSoft: primaryRedSoft ?? this.primaryRedSoft,
      surface: surface ?? this.surface,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      elevated: elevated ?? this.elevated,
      border: border ?? this.border,
      btnText: btnText ?? this.btnText,
      chatCardColor: chatCardColor ?? this.chatCardColor,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      white: white ?? this.white,
      black: black ?? this.black,
      blue: blue ?? this.blue,
      orange: orange ?? this.orange,
      amber: amber ?? this.amber,
      red: red ?? this.red,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryHover:
          Color.lerp(primaryHover, other.primaryHover, t) ?? primaryHover,
      primaryRedSoft:
          Color.lerp(primaryRedSoft, other.primaryRedSoft, t) ?? primaryRedSoft,
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
      chatCardColor:
          Color.lerp(chatCardColor, other.chatCardColor, t) ?? chatCardColor,

      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,

      white: Color.lerp(white, other.white, t) ?? white,
      black: Color.lerp(black, other.black, t) ?? black,
      blue: Color.lerp(blue, other.blue, t) ?? blue,
      orange: Color.lerp(orange, other.orange, t) ?? orange,
      amber: Color.lerp(amber, other.amber, t) ?? amber,
      red: Color.lerp(red, other.red, t) ?? red,
    );
  }
}
