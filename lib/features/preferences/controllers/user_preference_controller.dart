import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final userPreferenceControllerProvider =
    StateNotifierProvider<UserPreferenceController, UserPreferenceState>((ref) {
      final storage = ref.watch(onboardingStorageProvider);
      return UserPreferenceController(storage);
    });

class UserPreferenceController extends StateNotifier<UserPreferenceState> {
  final OnboardingStorage _storage;

  UserPreferenceController(this._storage)
    : super(UserPreferenceState.initial()) {
    _load();
  }

  /// Load saved preferences from SharedPreferences
  void _load() {
    final prefs = _storage.loadPreferences();
    state = prefs;
  }

  /// Sync preferences received from API (after login)
  Future<void> syncFromServer({
    required String languageCode,
    required String countryCode,
    required String currencyCode,
  }) async {
    state = state.copyWith(isLoading: true);

    final updated = UserPreferenceState(
      languageCode: UserPreferenceState.normalizeLanguageCode(languageCode),
      countryCode: UserPreferenceState.normalizeCountryCode(countryCode),
      currencyCode: UserPreferenceState.normalizeCurrencyCode(currencyCode),
    );

    await _storage.savePreferences(updated);

    state = updated.copyWith(isLoading: false);
  }

  /// Update language
  Future<void> updateLanguageCode(String languageCode) async {
    state = state.copyWith(isSaving: true);

    final updated = state.copyWith(
      languageCode: UserPreferenceState.normalizeLanguageCode(languageCode),
    );

    await _storage.savePreferences(updated);

    state = updated.copyWith(isSaving: false);
  }

  /// Update country
  Future<void> updateCountryCode(String countryCode) async {
    state = state.copyWith(isSaving: true);

    final updated = state.copyWith(
      countryCode: UserPreferenceState.normalizeCountryCode(countryCode),
    );

    await _storage.savePreferences(updated);

    state = updated.copyWith(isSaving: false);
  }

  /// Update currency
  Future<void> updateCurrencyCode(String currencyCode) async {
    state = state.copyWith(isSaving: true);

    final updated = state.copyWith(
      currencyCode: UserPreferenceState.normalizeCurrencyCode(currencyCode),
    );

    await _storage.savePreferences(updated);

    state = updated.copyWith(isSaving: false);
  }

  /// Update multiple preferences at once
  Future<void> updatePreferences({
    String? languageCode,
    String? countryCode,
    String? currencyCode,
  }) async {
    state = state.copyWith(isSaving: true);

    final updated = state.copyWith(
      languageCode: languageCode == null
          ? null
          : UserPreferenceState.normalizeLanguageCode(languageCode),
      countryCode: countryCode == null
          ? null
          : UserPreferenceState.normalizeCountryCode(countryCode),
      currencyCode: currencyCode == null
          ? null
          : UserPreferenceState.normalizeCurrencyCode(currencyCode),
    );

    await _storage.savePreferences(updated);

    state = updated.copyWith(isSaving: false);
  }

  /// Reset preferences (dev/testing only)
  Future<void> reset() async {
    state = state.copyWith(isSaving: true);

    await _storage.clearAll();

    state = UserPreferenceState.initial();
  }
}
