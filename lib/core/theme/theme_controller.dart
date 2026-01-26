import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/theme_prefs.dart';

class ThemeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    return (await ThemePrefs.readThemeMode()) ?? ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncValue.data(mode);
    await ThemePrefs.writeThemeMode(mode);
  }
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
