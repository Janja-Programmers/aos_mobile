import 'dart:convert';

import 'package:africaonlinestores/features/preferences/models/active_preference_snapshot.dart';
import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  OnboardingStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _keyActiveSnapshot = 'aos_active_preference_snapshot_v1';
  static const _keyGuestSnapshot = 'aos_guest_preference_snapshot_v1';
  static const _keyOnboardingCompleted = 'onboarding_completed';

  static const _legacyCountryCode = 'pref_country_code';
  static const _legacyLanguageCode = 'pref_language_code';
  static const _legacyCurrencyCode = 'pref_currency_code';

  Future<void> savePreferences(UserPreferenceState preferences) async {
    final snapshot = preferences.snapshot;
    if (snapshot == null || !snapshot.isValid) {
      throw const FormatException(
        'Cannot persist an invalid preference snapshot.',
      );
    }
    await saveActiveSnapshot(snapshot);
  }

  Future<void> saveActiveSnapshot(ActivePreferenceSnapshot snapshot) async {
    if (!snapshot.isValid) {
      throw const FormatException(
        'Cannot persist an invalid preference snapshot.',
      );
    }

    final encoded = jsonEncode(snapshot.toJson());
    final saved = await _prefs.setString(_keyActiveSnapshot, encoded);
    if (!saved) {
      throw Exception('Failed to persist the active preference snapshot.');
    }
  }

  Future<void> saveGuestSnapshot(ActivePreferenceSnapshot snapshot) async {
    if (!snapshot.isValid || !snapshot.isGuest) return;
    final saved = await _prefs.setString(
      _keyGuestSnapshot,
      jsonEncode(snapshot.toJson()),
    );
    if (!saved) {
      throw Exception('Failed to persist the guest preference snapshot.');
    }
  }

  UserPreferenceState loadPreferences() {
    final snapshot = _readSnapshot(_keyActiveSnapshot) ?? _migrateLegacy();
    return UserPreferenceState(snapshot: snapshot);
  }

  ActivePreferenceSnapshot? loadGuestSnapshot() {
    return _readSnapshot(_keyGuestSnapshot);
  }

  ActivePreferenceSnapshot? _readSnapshot(String key) {
    try {
      final String? raw = _readStoredString(key);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<Object?, Object?>) return null;
      final snapshot = ActivePreferenceSnapshot.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      return snapshot.isValid ? snapshot : null;
    } on FormatException {
      return null;
    }
  }

  ActivePreferenceSnapshot? _migrateLegacy() {
    final String country = _readStoredString(_legacyCountryCode) ?? '';
    final String language = _readStoredString(_legacyLanguageCode) ?? '';
    final String currency = _readStoredString(_legacyCurrencyCode) ?? '';
    if (country.isEmpty || language.isEmpty || currency.isEmpty) return null;

    return ActivePreferenceSnapshot.legacy(
      country: country,
      language: language,
      currency: currency,
    );
  }

  String? _readStoredString(String key) {
    final Object? value = _prefs.get(key);
    if (value is! String) return null;

    final String clean = value.trim();
    return clean.isEmpty ? null : clean;
  }

  Future<void> markOnboardingComplete() async {
    final current = loadPreferences();
    if (!current.hasValidPreference) {
      throw StateError(
        'Onboarding cannot complete without a valid preference snapshot.',
      );
    }

    final saved = await _prefs.setBool(_keyOnboardingCompleted, true);
    if (!saved) {
      throw Exception('Failed to persist onboarding completion.');
    }
  }

  bool isOnboardingComplete() {
    return (_prefs.getBool(_keyOnboardingCompleted) ?? false) &&
        loadPreferences().hasValidPreference;
  }

  Future<void> clearOnboardingFlag() async {
    await _prefs.remove(_keyOnboardingCompleted);
  }

  Future<void> clearActivePreference() async {
    await _prefs.remove(_keyActiveSnapshot);
  }

  Future<void> clearAll() async {
    await Future.wait(<Future<bool>>[
      _prefs.remove(_keyActiveSnapshot),
      _prefs.remove(_keyGuestSnapshot),
      _prefs.remove(_legacyCountryCode),
      _prefs.remove(_legacyLanguageCode),
      _prefs.remove(_legacyCurrencyCode),
      _prefs.remove(_keyOnboardingCompleted),
    ]);
  }
}
