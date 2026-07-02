import 'package:africaonlinestores/core/theme/theme_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController(super.initialState);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ThemePrefs.writeThemeMode(mode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>(
  (ref) => throw UnimplementedError(),
);
