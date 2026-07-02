import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(12));

  static ThemeData light() {
    const tokens = AppColorTokens.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.primary,
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
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
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

      popupMenuTheme: PopupMenuThemeData(
        color: tokens.elevated,
        surfaceTintColor: Colors.transparent,
        shadowColor: tokens.black.withValues(alpha: 0.12),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.border),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: tokens.surface,
        headerBackgroundColor: tokens.primary,
        headerForegroundColor: tokens.white,
        todayForegroundColor: WidgetStatePropertyAll(tokens.primary),
        todayBorder: BorderSide(color: tokens.primary),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.white;
          }
          return tokens.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.primary;
          }
          return null;
        }),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: tokens.primary,
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: tokens.textMuted,
        ),
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: tokens.surface,
        hourMinuteColor: tokens.border,
        hourMinuteTextColor: tokens.textPrimary,
        dialBackgroundColor: tokens.border,
        dialHandColor: tokens.primary,
        entryModeIconColor: tokens.primary,
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: tokens.primary,
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: tokens.textMuted,
        ),
      ),
    );
  }

  static ThemeData dark() {
    const tokens = AppColorTokens.dark;

    // You can also use fromSeed here. Your current dark scheme is fine.
    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.primary,
      brightness: Brightness.dark,
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

        hintStyle: TextStyle(color: tokens.textMuted),
        labelStyle: TextStyle(color: tokens.textMuted),
        floatingLabelStyle: TextStyle(color: tokens.textPrimary),
        errorStyle: TextStyle(color: scheme.error),
        isDense: true,

        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: tokens.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
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

      popupMenuTheme: PopupMenuThemeData(
        color: tokens.elevated,
        surfaceTintColor: Colors.transparent,
        shadowColor: tokens.black.withValues(alpha: 0.12),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.border),
        ),
      ),
    );
  }
}
