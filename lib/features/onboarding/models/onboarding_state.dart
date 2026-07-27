import 'package:africaonlinestores/features/localization/models/localization_models.dart';

class OnboardingState {
  const OnboardingState({
    required this.step,
    required this.didInitialize,
    required this.isCompleting,
    this.language,
    this.country,
    this.currency,
    this.initialResolvedCountry,
    this.error,
  });

  factory OnboardingState.initial() {
    return const OnboardingState(
      step: 0,
      didInitialize: false,
      isCompleting: false,
    );
  }

  final int step;
  final LanguageOption? language;
  final CountryOption? country;
  final CurrencyOption? currency;
  final CountryOption? initialResolvedCountry;
  final bool didInitialize;
  final bool isCompleting;
  final String? error;

  String? get languageId => language?.canonicalId;
  String? get countryId => country?.canonicalId;
  String? get currencyId => currency?.canonicalId;

  bool get hasValidSelection =>
      language != null &&
      country != null &&
      currency != null &&
      language!.enabled &&
      country!.enabled &&
      currency!.enabled;

  OnboardingState copyWith({
    int? step,
    LanguageOption? language,
    CountryOption? country,
    CurrencyOption? currency,
    CountryOption? initialResolvedCountry,
    bool? didInitialize,
    bool? isCompleting,
    String? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      language: language ?? this.language,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      initialResolvedCountry:
          initialResolvedCountry ?? this.initialResolvedCountry,
      didInitialize: didInitialize ?? this.didInitialize,
      isCompleting: isCompleting ?? this.isCompleting,
      error: clearError ? null : error ?? this.error,
    );
  }
}
