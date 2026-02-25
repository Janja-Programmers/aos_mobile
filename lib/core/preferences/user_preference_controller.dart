import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/localization/localization_state.dart';
import 'package:africaonlinestores/core/preferences/user_preference_state.dart';
import 'package:africaonlinestores/core/preferences/user_preference_store.dart';
import 'package:africaonlinestores/core/providers.dart';

class UserPreferenceController extends AsyncNotifier<UserPreferenceState?> {
  late final LocalizationState _localization;
  late final UserPreferenceStore _store;

  @override
  Future<UserPreferenceState?> build() async {
    _localization = await ref.read(localizationControllerProvider.future);

    _store = UserPreferenceStore();

    final local = await _store.read();
    return local;
  }

  /// Guest initialization (device detection)
  Future<void> initGuest({String? detectedCountry}) async {
    final current = state.value;
    if (current != null) return;

    if (detectedCountry != null &&
        _localization.countries.any((c) => c["code"] == detectedCountry)) {
      final newState = UserPreferenceState(
        country: detectedCountry,
        language: _localization.systemDefaultLanguage,
        currency: _localization.systemDefaultCurrency,
      );

      await _store.save(newState);
      state = AsyncData(newState);
    }
  }

  /// Update Local Language
  Future<void> updateLanguage(String code) async {
    if (!_localization.languages.any((l) => l["code"] == code)) {
      return;
    }

    final current = state.value;

    final newState = UserPreferenceState(
      country: current?.country,
      language: code,
      currency: current?.currency ?? _localization.systemDefaultCurrency,
    );

    await _store.save(newState);
    state = AsyncData(newState);
  }

  /// Update Local Country
  Future<void> updateCountry(String code) async {
    if (!_localization.countries.any((c) => c["code"] == code)) {
      return;
    }

    final current = state.value;

    final newState = UserPreferenceState(
      country: code,
      language: current?.language ?? _localization.systemDefaultLanguage,
      currency: current?.currency ?? _localization.systemDefaultCurrency,
    );

    state = const AsyncLoading();

    await _store.save(newState);

    state = AsyncData(newState);
  }

  /// Sync when user logs in
  Future<void> syncOnLogin({
    required Future<Either<Failure, Map<String, dynamic>>> Function()
    getRemotePrefs,
    required Future<Either<Failure, void>> Function(Map<String, dynamic>)
    updateRemotePrefs,
  }) async {
    final res = await getRemotePrefs();

    if (res.isLeft) return;

    final payload = res.rightOrNull ?? {};
    final data = payload["data"];

    if (data != null) {
      final remoteState = UserPreferenceState(
        country: data["country"]?["code"],
        language: data["language"]?["code"],
        currency: data["currency"]?["code"],
      );

      await _store.save(remoteState);
      state = AsyncData(remoteState);
    } else {
      final local = state.value;
      if (local != null) {
        await updateRemotePrefs(local.toJson());
      }
    }
  }

  /// Manual update from settings page
  Future<void> updatePreference(
    UserPreferenceState newState,
    Future<void> Function(Map<String, dynamic>)? updateRemotePrefs,
  ) async {
    state = const AsyncLoading();

    await _store.save(newState);

    state = AsyncData(newState);

    if (updateRemotePrefs != null) {
      await updateRemotePrefs(newState.toJson());
    }
  }
}
