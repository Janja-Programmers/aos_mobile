import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePrefs {
  static const _key = 'theme_mode';

  static Future<ThemeMode?> readThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static Future<void> writeThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _encode(mode));
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
