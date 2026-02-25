class LocalizationState {
  final List<Map<String, dynamic>> countries;
  final List<Map<String, dynamic>> languages;
  final List<Map<String, dynamic>> currencies;

  final String? systemDefaultCountry;
  final String? systemDefaultLanguage;
  final String? systemDefaultCurrency;

  LocalizationState({
    required this.countries,
    required this.languages,
    required this.currencies,
    required this.systemDefaultCountry,
    required this.systemDefaultLanguage,
    required this.systemDefaultCurrency,
  });
}
