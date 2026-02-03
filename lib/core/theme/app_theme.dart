import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';

class AppTheme {
  AppTheme._();

  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(22));

  static ThemeData light() {
    const tokens = AppColorTokens.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.primary,
      brightness: Brightness.light,
      surfaceBright: tokens.surfaceBright,
      surface: tokens.surface,
      primary: tokens.primary,
      onPrimary: tokens.primaryHover,
      tertiary: tokens.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: const <ThemeExtension<dynamic>>[tokens],

      scaffoldBackgroundColor: tokens.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.surface,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
        labelStyle: TextStyle(color: tokens.textMuted),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: pill),
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData dark() {
    const tokens = AppColorTokens.dark;

    // You can also use fromSeed here. Your current dark scheme is fine.
    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.primary,
      brightness: Brightness.light,
      surfaceBright: tokens.surface,
      surface: tokens.surface,
      primary: tokens.primary,
      onPrimary: tokens.primaryHover,
      tertiary: tokens.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: const <ThemeExtension<dynamic>>[tokens],

      scaffoldBackgroundColor: tokens.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
        labelStyle: TextStyle(color: tokens.textMuted),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: pill),
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
