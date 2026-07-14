import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  OnboardingStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Storage Keys
  static const _keyCountryCode = 'pref_country_code';
  static const _keyLanguageCode = 'pref_language_code';
  static const _keyCurrencyCode = 'pref_currency_code';
  static const _keyOnboardingCompleted = 'onboarding_completed';

  /// -----------------------------
  /// Preferences
  /// -----------------------------

  /// Save all user preference codes
  Future<void> savePreferences(UserPreferenceState prefs) async {
    await Future.wait([
      _prefs.setString(
        _keyCountryCode,
        UserPreferenceState.normalizeCountryCode(prefs.countryCode),
      ),
      _prefs.setString(
        _keyLanguageCode,
        UserPreferenceState.normalizeLanguageCode(prefs.languageCode),
      ),
      _prefs.setString(
        _keyCurrencyCode,
        UserPreferenceState.normalizeCurrencyCode(prefs.currencyCode),
      ),
    ]);
  }

  /// Save preferences directly from API payload
  Future<void> savePreferencesFromApi({
    required String countryCode,
    required String languageCode,
    required String currencyCode,
  }) async {
    await Future.wait([
      _prefs.setString(
        _keyCountryCode,
        UserPreferenceState.normalizeCountryCode(countryCode),
      ),
      _prefs.setString(
        _keyLanguageCode,
        UserPreferenceState.normalizeLanguageCode(languageCode),
      ),
      _prefs.setString(
        _keyCurrencyCode,
        UserPreferenceState.normalizeCurrencyCode(currencyCode),
      ),
    ]);
  }

  /// Update individual preference fields

  Future<void> setCountryCode(String code) async {
    await _prefs.setString(
      _keyCountryCode,
      UserPreferenceState.normalizeCountryCode(code),
    );
  }

  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(
      _keyLanguageCode,
      UserPreferenceState.normalizeLanguageCode(code),
    );
  }

  Future<void> setCurrencyCode(String code) async {
    await _prefs.setString(
      _keyCurrencyCode,
      UserPreferenceState.normalizeCurrencyCode(code),
    );
  }

  /// Load stored preferences (source of truth for UI)
  UserPreferenceState loadPreferences() {
    final countryCode = _prefs.getString(_keyCountryCode) ?? '';
    final languageCode = _prefs.getString(_keyLanguageCode) ?? '';
    final currencyCode = _prefs.getString(_keyCurrencyCode) ?? '';

    return UserPreferenceState(
      countryCode: countryCode,
      languageCode: languageCode,
      currencyCode: currencyCode,
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
  /// Reset onboarding only
  /// (DO NOT remove preferences on logout)
  /// -----------------------------

  Future<void> clearOnboardingFlag() async {
    await _prefs.remove(_keyOnboardingCompleted);
  }

  /// -----------------------------
  /// Dev reset (rarely used)
  /// -----------------------------

  Future<void> clearAll() async {
    await Future.wait([
      _prefs.remove(_keyCountryCode),
      _prefs.remove(_keyLanguageCode),
      _prefs.remove(_keyCurrencyCode),
      _prefs.remove(_keyOnboardingCompleted),
    ]);
  }
}
