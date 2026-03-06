class UserPreferenceState {
  final String language;
  final String country;
  final String currency;
  final bool isSaving;
  final bool isLoading;
  final String? error;

  const UserPreferenceState({
    required this.language,
    required this.country,
    required this.currency,
    this.isSaving = false,
    this.isLoading = false,
    this.error,
  });

  factory UserPreferenceState.initial() {
    return const UserPreferenceState(
      language: 'en',
      country: 'US',
      currency: 'USD',
    );
  }

  factory UserPreferenceState.loading() {
    return const UserPreferenceState(
      language: 'en',
      country: 'US',
      currency: 'USD',
      isLoading: true,
    );
  }

  factory UserPreferenceState.error(String message) {
    return UserPreferenceState(
      language: 'en',
      country: 'US',
      currency: 'USD',
      error: message,
    );
  }

  UserPreferenceState copyWith({
    String? language,
    String? country,
    String? currency,
    bool? isSaving,
    bool? isLoading,
    String? error,
  }) {
    return UserPreferenceState(
      language: language ?? this.language,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() => {
    "country": country,
    "language": language,
    "currency": currency,
  };

  factory UserPreferenceState.fromJson(Map<String, dynamic> json) {
    return UserPreferenceState(
      country: json["country"],
      language: json["language"],
      currency: json["currency"],
    );
  }

  @override
  String toString() {
    return 'UserPreferenceState(country: $country, language: $language, currency: $currency)';
  }
}
