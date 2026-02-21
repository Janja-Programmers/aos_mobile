import 'dart:ui';

import 'package:africaonlinestores/core/localization/locale_prefs.dart';

Locale? resolveLocale(LocalePrefs? prefs) {
  if (prefs == null) return null;

  if (prefs.languageCode.isEmpty) return null;

  return prefs.countryCode.isEmpty
      ? Locale(prefs.languageCode)
      : Locale(prefs.languageCode, prefs.countryCode);
}
