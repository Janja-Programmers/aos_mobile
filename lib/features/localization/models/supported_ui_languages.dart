import 'package:flutter/widgets.dart';

const Set<String> kSupportedUiLanguageCodes = <String>{
  'en',
  'ar',
  'fr',
  'sw',
  'zh',
};

const List<Locale> kSupportedUiLocales = <Locale>[
  Locale('en'),
  Locale('sw'),
  Locale('fr'),
  Locale('ar'),
  Locale('zh'),
];

String normalizeUiLanguageCode(String value) {
  final clean = value.trim().toLowerCase();
  if (clean.isEmpty) return '';
  return clean.split(RegExp('[-_]')).first;
}
