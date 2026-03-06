class LocalizationState {
  final List<Map<String, dynamic>> countries;
  final List<Map<String, dynamic>> languages;
  final List<Map<String, dynamic>> currencies;

  final bool isLoading;
  final String? error;

  const LocalizationState({
    required this.countries,
    required this.languages,
    required this.currencies,
    this.isLoading = false,
    this.error,
  });

  factory LocalizationState.initial() {
    return const LocalizationState(
      countries: [],
      languages: [],
      currencies: [],
      isLoading: true,
    );
  }

  LocalizationState copyWith({
    List<Map<String, dynamic>>? countries,
    List<Map<String, dynamic>>? languages,
    List<Map<String, dynamic>>? currencies,
    bool? isLoading,
    String? error,
  }) {
    return LocalizationState(
      countries: countries ?? this.countries,
      languages: languages ?? this.languages,
      currencies: currencies ?? this.currencies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
