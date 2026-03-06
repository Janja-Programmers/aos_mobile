class OnboardingState {
  final int step;
  final String? language;
  final String? country;
  final String? currency;
  final bool didInitDefaults;

  const OnboardingState({
    required this.step,
    this.language,
    this.country,
    this.currency,
    this.didInitDefaults = false,
  });

  factory OnboardingState.initial() {
    return const OnboardingState(step: 0, didInitDefaults: false);
  }

  OnboardingState copyWith({
    int? step,
    String? language,
    String? country,
    String? currency,
    bool? didInitDefaults,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      language: language ?? this.language,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      didInitDefaults: didInitDefaults ?? this.didInitDefaults,
    );
  }
}
