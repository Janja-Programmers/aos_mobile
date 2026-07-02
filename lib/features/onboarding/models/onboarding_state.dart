class OnboardingState {
  final int step;

  final String? languageCode;
  final String? countryCode;
  final String? currencyCode;

  final bool didInitDefaults;

  const OnboardingState({
    required this.step,
    this.languageCode,
    this.countryCode,
    this.currencyCode,
    required this.didInitDefaults,
  });

  factory OnboardingState.initial() {
    return const OnboardingState(step: 0, didInitDefaults: false);
  }

  OnboardingState copyWith({
    int? step,
    String? languageCode,
    String? countryCode,
    String? currencyCode,
    bool? didInitDefaults,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      didInitDefaults: didInitDefaults ?? this.didInitDefaults,
    );
  }
}
