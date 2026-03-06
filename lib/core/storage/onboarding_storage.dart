import 'package:shared_preferences/shared_preferences.dart';

import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';

class OnboardingStorage {
  OnboardingStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Storage Keys
  static const _keyCountry = "pref_country";
  static const _keyLanguage = "pref_language";
  static const _keyCurrency = "pref_currency";
  static const _keyOnboardingCompleted = "onboarding_completed";

  /// -----------------------------
  /// Preferences
  /// -----------------------------

  /// Save user preferences
  Future<void> savePreferences(UserPreferenceState prefs) async {
    await _prefs.setString(_keyCountry, prefs.country);

    await _prefs.setString(_keyLanguage, prefs.language);

    await _prefs.setString(_keyCurrency, prefs.currency);
  }

  /// Load stored preferences
  UserPreferenceState loadPreferences() {
    return UserPreferenceState(
      country: _prefs.getString(_keyCountry) ?? '',
      language: _prefs.getString(_keyLanguage) ?? '',
      currency: _prefs.getString(_keyCurrency) ?? '',
    );
  }

  /// -----------------------------
  /// Onboarding Flag
  /// -----------------------------

  Future<void> markOnboardingComplete() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }

  bool isOnboardingComplete() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// -----------------------------
  /// Reset (useful for logout/dev)
  /// -----------------------------

  Future<void> clear() async {
    await _prefs.remove(_keyCountry);
    await _prefs.remove(_keyLanguage);
    await _prefs.remove(_keyCurrency);
    await _prefs.remove(_keyOnboardingCompleted);
  }
}
