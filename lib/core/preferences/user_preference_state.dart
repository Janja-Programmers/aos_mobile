class UserPreferenceState {
  final String? country;
  final String? language;
  final String? currency;

  UserPreferenceState({
    required this.country,
    required this.language,
    required this.currency,
  });

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
}
