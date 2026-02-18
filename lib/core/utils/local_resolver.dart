import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/localization/locale_prefs.dart';

Locale? resolveLocale(AsyncValue<LocalePrefs> prefsAsync) {
  final prefs = prefsAsync.maybeWhen(data: (v) => v, orElse: () => null);

  if (prefs == null) return null;

  final lang = prefs.languageCode;
  final country = prefs.countryCode;

  if (lang.isEmpty) return null;
  return country.isEmpty ? Locale(lang) : Locale(lang, country);
}
