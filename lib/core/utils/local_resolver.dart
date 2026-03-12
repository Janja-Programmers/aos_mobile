import 'dart:ui';

import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';

import 'package:flutter/widgets.dart';

const List<Locale> kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('sw'),
  Locale('fr'),
  Locale('ar'),
  Locale('zh'),
];

Locale? resolveLocale(UserPreferenceState? prefs) {
  final raw = prefs?.languageCode;
  if (raw == null) return null;

  final code = raw.trim().toLowerCase();
  if (code.isEmpty) return null;

  // Example: if someone accidentally saves "en-US", normalize to "en"
  final normalized = code.split(RegExp(r'[-_]')).first;

  // Validate against supported locales
  for (final loc in kSupportedLocales) {
    if (loc.languageCode.toLowerCase() == normalized) {
      return loc;
    }
  }

  return const Locale('en');
}
