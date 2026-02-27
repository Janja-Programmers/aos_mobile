import 'package:flutter/material.dart';

Locale systemLocale() => WidgetsBinding.instance.platformDispatcher.locale;

String systemLanguageCode() => systemLocale().languageCode;

String? systemCountryCode() => systemLocale().countryCode;
