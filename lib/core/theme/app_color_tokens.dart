import 'package:flutter/material.dart';

/// Theme-aware color tokens for the app.
/// Add to ThemeData.extensions and read via: `context.appColors`.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.bg,
    required this.text,
    required this.muted,
    required this.fieldBg,
    required this.stroke,
  });

  final Color bg;
  final Color text;
  final Color muted;
  final Color fieldBg;
  final Color stroke;

  static const light = AppColorTokens(
    bg: Colors.white,
    text: Color(0xFF111111),
    muted: Color(0xFF9AA0A6),
    fieldBg: Color(0xFFF6F7F9),
    stroke: Color(0xFFE6E8EC),
  );

  static const dark = AppColorTokens(
    bg: Color(0xFF0B0B0B),
    text: Color(0xFFF5F5F5),
    muted: Color(0xFF9AA0A6),
    fieldBg: Color(0xFF151515),
    stroke: Color(0xFF2A2A2A),
  );

  @override
  AppColorTokens copyWith({
    Color? bg,
    Color? text,
    Color? muted,
    Color? fieldBg,
    Color? stroke,
  }) {
    return AppColorTokens(
      bg: bg ?? this.bg,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      fieldBg: fieldBg ?? this.fieldBg,
      stroke: stroke ?? this.stroke,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      text: Color.lerp(text, other.text, t) ?? text,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
      fieldBg: Color.lerp(fieldBg, other.fieldBg, t) ?? fieldBg,
      stroke: Color.lerp(stroke, other.stroke, t) ?? stroke,
    );
  }
}
