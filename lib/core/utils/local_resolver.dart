import 'dart:ui';

import 'package:africaonlinestores/core/preferences/user_preference_state.dart';

Locale? resolveLocale(UserPreferenceState? prefs) {
  if (prefs == null) return null;

  final language = prefs.language?.toLowerCase();
  final country = prefs.country?.toUpperCase();

  if (language == null || language.isEmpty) return null;

  if (country == null || country.isEmpty) {
    return Locale(language);
  }

  return Locale(language, country);
}
