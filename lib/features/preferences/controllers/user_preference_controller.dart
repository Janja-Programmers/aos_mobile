import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';

import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';

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

  /// Load saved preferences from storage
  void _load() {
    final prefs = _storage.loadPreferences();
    state = prefs;
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    state = state.copyWith(isSaving: true);

    final updated = state.copyWith(language: language);
    await _storage.savePreferences(updated);

    state = updated.copyWith(isSaving: false);
  }

  /// Update country
  Future<void> updateCountry(String country) async {
    state = state.copyWith(isSaving: true);

    final updated = state.copyWith(country: country);
    await _storage.savePreferences(updated);

    state = updated.copyWith(isSaving: false);
  }

  /// Update currency
  Future<void> updateCurrency(String currency) async {
    state = state.copyWith(isSaving: true);

    final updated = state.copyWith(currency: currency);
    await _storage.savePreferences(updated);

    state = updated.copyWith(isSaving: false);
  }

  /// Update multiple preferences at once
  Future<void> updatePreferences({
    String? language,
    String? country,
    String? currency,
  }) async {
    state = state.copyWith(isSaving: true);

    final updated = state.copyWith(
      language: language,
      country: country,
      currency: currency,
    );

    await _storage.savePreferences(updated);

    state = updated.copyWith(isSaving: false);
  }

  /// Reset preferences (useful for logout/dev)
  Future<void> reset() async {
    state = state.copyWith(isSaving: true);

    await _storage.clear();

    state = UserPreferenceState.initial();
  }
}
