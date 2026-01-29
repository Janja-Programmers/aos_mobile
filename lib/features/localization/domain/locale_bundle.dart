class LocaleOption {
  const LocaleOption({required this.code, required this.label});

  final String code;
  final String label;

  static LocaleOption fromMap(Map<String, dynamic> m,
      {required String codeKey, required String labelKey}) {
    return LocaleOption(
      code: (m[codeKey] ?? '').toString(),
      label: (m[labelKey] ?? '').toString(),
    );
  }
}

class LocaleBundle {
  const LocaleBundle({
    required this.countries,
    required this.languages,
    required this.currencies,
    required this.baseCurrencyCode,
    required this.defaultLanguageCode,
    required this.defaultCountryCode,
  });

  final List<LocaleOption> countries;
  final List<LocaleOption> languages;
  final List<LocaleOption> currencies;

  final String baseCurrencyCode;
  final String defaultLanguageCode;
  final String defaultCountryCode;
}

class UserPreferencesDto {
  const UserPreferencesDto({
    required this.countryCode,
    required this.languageCode,
    required this.currencyCode,
    required this.timezone,
    required this.languageOverridden,
    required this.currencyOverridden,
  });

  final String countryCode;
  final String languageCode;
  final String currencyCode;
  final String timezone;
  final bool languageOverridden;
  final bool currencyOverridden;
}
