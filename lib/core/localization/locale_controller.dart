import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/localization/device_locale.dart';
import 'package:africaonlinestores/core/localization/locale_prefs.dart';
import 'package:africaonlinestores/core/localization/locale_prefs_store.dart';
import 'package:africaonlinestores/features/localization/data/localization_api.dart';
import 'package:africaonlinestores/features/localization/domain/locale_bundle.dart';

/// Locale preferences controller.
///
/// - Loads local prefs on startup (fast)
/// - If absent, detects device locale and uses backend config to pick defaults
/// - Applies the context headers to [ApiClient]
/// - Provides methods for manual overrides
class LocaleController extends AsyncNotifier<LocalePrefs> {
  late final LocalePrefsStore _store;
  late final LocalizationApi _api;
  ApiClient? _apiClient;

  @override
  Future<LocalePrefs> build() async {
    _store = ref.read(localePrefsStoreProvider);
    _api = ref.read(localizationApiProvider);
    _apiClient = ref.read(apiClientProvider);

    // 1) Load local prefs (fast path)
    final local = await _store.read();
    if (local != null && local.countryCode.isNotEmpty) {
      _applyToApi(local);
      return local;
    }

    // 2) Bootstrap from device + backend bundle
    final device = detectDeviceLocale();
    final bundleEither = await _api.getLocaleBundle();
    final bundle = bundleEither.rightOrNull;

    final defaultCountry =
        (device.countryCode != null && device.countryCode!.isNotEmpty)
        ? device.countryCode!
        : (bundle?.defaultCountryCode ?? 'KE');

    // Language: prefer device language when possible, otherwise bundle default.
    final deviceLang = device.languageCode;
    final supportedLangs =
        bundle?.languages.map((e) => e.code).toSet() ?? const <String>{};
    final pickedLang = supportedLangs.contains(deviceLang)
        ? deviceLang
        : (bundle?.defaultLanguageCode ?? 'en');

    // Currency: use base/default from bundle (or USD).
    final pickedCurrency = bundle?.baseCurrencyCode ?? 'USD';

    final prefs = LocalePrefs(
      countryCode: defaultCountry,
      languageCode: pickedLang,
      currencyCode: pickedCurrency,
      timezone: device.timezone,
      languageOverridden: false,
      currencyOverridden: false,
    );

    await _store.write(prefs);
    _applyToApi(prefs);
    return prefs;
  }

  LocalePrefs? _currentOrNull() {
    return state.maybeWhen(data: (v) => v, orElse: () => null);
  }

  void _applyToApi(LocalePrefs prefs) {
    _apiClient?.setContext(
      countryCode: prefs.countryCode,
      languageCode: prefs.languageCode,
      currencyCode: prefs.currencyCode,
    );
  }

  Future<void> setCountry(String countryCode) async {
    final current = _currentOrNull();
    if (current == null) return;

    final next = current.copyWith(countryCode: countryCode);
    state = AsyncValue.data(next);
    await _store.write(next);
    _applyToApi(next);
  }

  Future<void> setLanguage(
    String languageCode, {
    bool overridden = true,
  }) async {
    final current = _currentOrNull();
    if (current == null) return;

    final next = current.copyWith(
      languageCode: languageCode,
      languageOverridden: overridden,
    );
    state = AsyncValue.data(next);
    await _store.write(next);
    _applyToApi(next);
  }

  Future<void> setCurrency(
    String currencyCode, {
    bool overridden = true,
  }) async {
    final current = _currentOrNull();
    if (current == null) return;

    final next = current.copyWith(
      currencyCode: currencyCode,
      currencyOverridden: overridden,
    );
    state = AsyncValue.data(next);
    await _store.write(next);
    _applyToApi(next);
  }

  /// Sync currently selected prefs to backend (requires login).
  ///
  /// Safe to call multiple times; server will upsert preferences.
  Future<void> syncToBackend() async {
    final current = _currentOrNull();
    if (current == null) return;

    await _api.updatePreferences(
      countryCode: current.countryCode,
      languageCode: current.languageCode,
      currencyCode: current.currencyCode,
      timezone: current.timezone,
      overrideLanguage: current.languageOverridden,
      overrideCurrency: current.currencyOverridden,
    );
  }

  /// Hydrate from backend preference record.
  ///
  /// Call this right after login so the app matches user account across devices.
  Future<void> refreshFromBackend() async {
    final res = await _api.getMyPreferences();
    final prefs = res.rightOrNull;
    if (prefs == null) return;
    if (prefs.countryCode.isEmpty) return;

    final current = _currentOrNull();

    final next = LocalePrefs(
      countryCode: prefs.countryCode,
      languageCode: prefs.languageCode,
      currencyCode: prefs.currencyCode,
      timezone: prefs.timezone.isEmpty
          ? (current?.timezone ?? 'UTC')
          : prefs.timezone,
      languageOverridden: prefs.languageOverridden,
      currencyOverridden: prefs.currencyOverridden,
    );

    state = AsyncValue.data(next);
    await _store.write(next);
    _applyToApi(next);
  }
}

final localePrefsStoreProvider = Provider<LocalePrefsStore>((ref) {
  return LocalePrefsStore();
});

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, LocalePrefs>(LocaleController.new);

final localeBundleProvider = FutureProvider<LocaleBundle>((ref) async {
  final api = ref.read(localizationApiProvider);
  final res = await api.getLocaleBundle();

  return res.fold(
    (failure) {
      throw failure; // FutureProvider will go to error state
    },
    (bundle) {
      return bundle;
    },
  );
});

class PreloadedLocaleController extends LocaleController {
  final LocalePrefs? initial;

  PreloadedLocaleController(this.initial);

  @override
  Future<LocalePrefs> build() async {
    _store = ref.read(localePrefsStoreProvider);
    _api = ref.read(localizationApiProvider);
    _apiClient = ref.read(apiClientProvider);

    if (initial != null) {
      _applyToApi(initial!);
      return initial!;
    }

    return super.build();
  }
}
