import 'package:africaonlinestores/features/preferences/models/active_preference_snapshot.dart';

class UserPreferenceState {
  const UserPreferenceState({
    required this.snapshot,
    this.isSaving = false,
    this.isLoading = false,
    this.error,
  });

  factory UserPreferenceState.initial() {
    return const UserPreferenceState(snapshot: null, isLoading: true);
  }

  factory UserPreferenceState.empty() {
    return const UserPreferenceState(snapshot: null);
  }

  factory UserPreferenceState.error(String message) {
    return UserPreferenceState(snapshot: null, error: message);
  }

  final ActivePreferenceSnapshot? snapshot;
  final bool isSaving;
  final bool isLoading;
  final String? error;

  bool get hasValidPreference => snapshot?.isValid ?? false;

  String get countryId => snapshot?.country.canonicalId ?? '';
  String get languageId => snapshot?.language.canonicalId ?? '';
  String get currencyId => snapshot?.currency.canonicalId ?? '';

  // Display-code compatibility aliases for existing presentation consumers.
  // Persistence and authentication must use the canonical *Id getters above.
  String get countryCode => snapshot?.country.displayCode ?? '';
  String get languageCode => snapshot?.language.displayCode ?? '';
  String get currencyCode => snapshot?.currency.displayCode ?? '';

  UserPreferenceState copyWith({
    ActivePreferenceSnapshot? snapshot,
    bool replaceSnapshot = false,
    bool? isSaving,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserPreferenceState(
      snapshot: replaceSnapshot ? snapshot : snapshot ?? this.snapshot,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'country': countryId,
      'language': languageId,
      'currency': currencyId,
    };
  }

  @override
  String toString() {
    return 'UserPreferenceState(countryId: $countryId, languageId: '
        '$languageId, currencyId: $currencyId, authority: '
        '${snapshot?.authority.name})';
  }
}
