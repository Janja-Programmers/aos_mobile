class UserPreferenceState {
  final String languageCode;
  final String countryCode;
  final String currencyCode;

  final bool isSaving;
  final bool isLoading;
  final String? error;

  const UserPreferenceState({
    required this.languageCode,
    required this.countryCode,
    required this.currencyCode,
    this.isSaving = false,
    this.isLoading = false,
    this.error,
  });

  /// Default preferences used before API / storage load
  factory UserPreferenceState.initial() {
    return const UserPreferenceState(
      languageCode: 'en',
      countryCode: 'US',
      currencyCode: 'USD',
    );
  }

  factory UserPreferenceState.loading() {
    return const UserPreferenceState(
      languageCode: 'en',
      countryCode: 'US',
      currencyCode: 'USD',
      isLoading: true,
    );
  }

  factory UserPreferenceState.error(String message) {
    return UserPreferenceState(
      languageCode: 'en',
      countryCode: 'US',
      currencyCode: 'USD',
      error: message,
    );
  }

  UserPreferenceState copyWith({
    String? languageCode,
    String? countryCode,
    String? currencyCode,
    bool? isSaving,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserPreferenceState(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  /// API payload format
  Map<String, dynamic> toJson() {
    return {
      "country": countryCode,
      "language": languageCode,
      "currency": currencyCode,
    };
  }

  factory UserPreferenceState.fromJson(Map<String, dynamic> json) {
    return UserPreferenceState(
      countryCode: (json["country"] ?? '').toString().toUpperCase(),
      languageCode: (json["language"] ?? 'en').toString().toLowerCase(),
      currencyCode: (json["currency"] ?? 'USD').toString().toUpperCase(),
    );
  }

  @override
  String toString() {
    return 'UserPreferenceState(countryCode: $countryCode, languageCode: $languageCode, currencyCode: $currencyCode)';
  }
}
