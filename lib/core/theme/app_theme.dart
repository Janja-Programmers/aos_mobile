import 'package:flutter/material.dart';

import 'package:aos_mobile/core/theme/app_color_tokens.dart';

class AppTheme {
  AppTheme._();

  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(22));

  static ThemeData light() {
    const tokens = AppColorTokens.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.light,
      surfaceBright: tokens.bg,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: const <ThemeExtension<dynamic>>[tokens],

      scaffoldBackgroundColor: tokens.bg,

      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bg,
        foregroundColor: tokens.text,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: tokens.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
        labelStyle: TextStyle(color: tokens.muted),
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
    final scheme = const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: Color(0xFF121212),
      onSurface: Color(0xFFF5F5F5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: const <ThemeExtension<dynamic>>[tokens],

      scaffoldBackgroundColor: tokens.bg,

      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bg,
        foregroundColor: tokens.text,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: tokens.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
        labelStyle: TextStyle(color: tokens.muted),
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
