import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/features/preferences/models/active_preference_snapshot.dart';
import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final userPreferenceControllerProvider =
    StateNotifierProvider<UserPreferenceController, UserPreferenceState>((ref) {
      final storage = ref.watch(onboardingStorageProvider);
      return UserPreferenceController(storage);
    });

class UserPreferenceController extends StateNotifier<UserPreferenceState> {
  UserPreferenceController(this._storage)
    : super(UserPreferenceState.initial()) {
    _load();
  }

  final OnboardingStorage _storage;

  void _load() {
    state = _storage.loadPreferences();
  }

  Future<void> initializeGuestFromResolution(
    ResolvedLocaleContext context,
  ) async {
    if (state.hasValidPreference) return;
    final snapshot = ActivePreferenceSnapshot.fromResolvedContext(context);
    await _persist(snapshot);
    await _saveGuestBackup(snapshot);
  }

  Future<void> replaceGuestSnapshot(ActivePreferenceSnapshot snapshot) async {
    if (!snapshot.isValid || !snapshot.isGuest) {
      throw const FormatException('A valid guest snapshot is required.');
    }
    await _persist(snapshot);
    await _saveGuestBackup(snapshot);
  }

  Future<void> replaceAuthenticatedSnapshot(
    ActivePreferenceSnapshot snapshot,
  ) async {
    if (!snapshot.isValid || snapshot.isGuest) {
      throw const FormatException(
        'A valid authenticated snapshot is required.',
      );
    }

    final current = state.snapshot;
    if (current != null && current.isValid && current.isGuest) {
      await _saveGuestBackup(current);
    }
    await _persist(snapshot);
  }

  Future<void> syncFromServerPreferences(
    Map<String, dynamic> preferences, {
    required PreferenceAuthority authority,
  }) async {
    final snapshot = ActivePreferenceSnapshot.fromServerPreferences(
      preferences,
      authority: authority,
    );
    await replaceAuthenticatedSnapshot(snapshot);
  }

  Future<bool> restoreGuestSnapshot() async {
    final guest = _storage.loadGuestSnapshot();
    if (guest == null || !guest.isValid) {
      final current = state.snapshot;
      if (current != null && current.isValid && current.isGuest) return true;

      await _storage.clearActivePreference();
      state = UserPreferenceState.empty();
      return false;
    }

    final restored = guest.copyWith(
      authority: PreferenceAuthority.offlineRestoration,
    );
    await _persist(restored);
    return true;
  }

  Future<void> updateLanguage(LanguageOption language) async {
    final current = _requireSnapshot();
    final updated = current.copyWith(
      language: PreferenceSelection.fromLanguage(
        language,
        source: LocaleResolutionSource.request,
      ),
      authority: PreferenceAuthority.guestManual,
    );
    await replaceGuestSnapshot(updated);
  }

  Future<void> updateCountry(CountryOption country) async {
    final current = _requireSnapshot();
    final updated = current.copyWith(
      country: PreferenceSelection.fromCountry(
        country,
        source: LocaleResolutionSource.request,
      ),
      authority: PreferenceAuthority.guestManual,
    );
    await replaceGuestSnapshot(updated);
  }

  Future<void> updateCurrency(CurrencyOption currency) async {
    final current = _requireSnapshot();
    final updated = current.copyWith(
      currency: PreferenceSelection.fromCurrency(
        currency,
        source: LocaleResolutionSource.request,
      ),
      authority: PreferenceAuthority.guestManual,
    );
    await replaceGuestSnapshot(updated);
  }

  Future<void> _saveGuestBackup(ActivePreferenceSnapshot snapshot) async {
    try {
      await _storage.saveGuestSnapshot(snapshot);
    } on Exception catch (error) {
      appLogger.w('[Preferences] Guest backup could not be persisted: $error');
    }
  }

  Future<void> _persist(ActivePreferenceSnapshot snapshot) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _storage.saveActiveSnapshot(snapshot);
      state = UserPreferenceState(snapshot: snapshot);
    } catch (error) {
      state = state.copyWith(isSaving: false, error: error.toString());
      rethrow;
    }
  }

  ActivePreferenceSnapshot _requireSnapshot() {
    final current = state.snapshot;
    if (current == null || !current.isValid) {
      throw StateError('A valid active preference snapshot is required.');
    }
    return current;
  }
}
