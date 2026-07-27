import 'dart:ui';

import 'package:africaonlinestores/features/localization/models/supported_ui_languages.dart';
import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:flutter/widgets.dart';

const List<Locale> kSupportedLocales = kSupportedUiLocales;

Locale? resolveLocale(UserPreferenceState? preferences) {
  final raw = preferences?.snapshot?.language.displayCode;
  if (raw == null) return null;

  final normalized = normalizeUiLanguageCode(raw);
  if (normalized.isEmpty || !kSupportedUiLanguageCodes.contains(normalized)) {
    return null;
  }

  for (final locale in kSupportedLocales) {
    if (locale.languageCode.toLowerCase() == normalized) return locale;
  }
  return null;
}
