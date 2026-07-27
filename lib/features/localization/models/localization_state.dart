import 'package:africaonlinestores/features/localization/models/localization_models.dart';

class LocalizationState {
  const LocalizationState({
    required this.countries,
    required this.languages,
    required this.currencies,
    required this.isLoading,
    this.defaults,
    this.resolvedContext,
    this.schemaVersion = '',
    this.error,
  });

  factory LocalizationState.initial() {
    return const LocalizationState(
      countries: <CountryOption>[],
      languages: <LanguageOption>[],
      currencies: <CurrencyOption>[],
      isLoading: true,
    );
  }

  final List<CountryOption> countries;
  final List<LanguageOption> languages;
  final List<CurrencyOption> currencies;
  final LocaleBundleDefaults? defaults;
  final ResolvedLocaleContext? resolvedContext;
  final String schemaVersion;
  final bool isLoading;
  final String? error;

  bool get isReady => !isLoading && error == null && resolvedContext != null;

  LocalizationState copyWith({
    List<CountryOption>? countries,
    List<LanguageOption>? languages,
    List<CurrencyOption>? currencies,
    LocaleBundleDefaults? defaults,
    ResolvedLocaleContext? resolvedContext,
    String? schemaVersion,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LocalizationState(
      countries: countries ?? this.countries,
      languages: languages ?? this.languages,
      currencies: currencies ?? this.currencies,
      defaults: defaults ?? this.defaults,
      resolvedContext: resolvedContext ?? this.resolvedContext,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
