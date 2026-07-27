import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/localization/models/locale_presentation_catalog.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/features/onboarding/models/onboarding_state.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/preferences/models/active_preference_snapshot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
      return OnboardingController(ref);
    });

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this.ref) : super(OnboardingState.initial());

  final Ref ref;
  Future<void>? _initializeFuture;
  Future<void>? _completionFuture;

  Future<void> initializeIfNeeded() {
    if (state.didInitialize) return Future<void>.value();
    final existing = _initializeFuture;
    if (existing != null) return existing;

    final future = _initialize();
    _initializeFuture = future;
    return future.whenComplete(() {
      if (identical(_initializeFuture, future)) _initializeFuture = null;
    });
  }

  Future<void> _initialize() async {
    try {
      await _initializeResolvedContext();
    } catch (error) {
      state = state.copyWith(didInitialize: true, error: error.toString());
    }
  }

  Future<void> _initializeResolvedContext() async {
    final localization = ref.read(localizationControllerProvider);
    final resolved = localization.resolvedContext;
    if (!localization.isReady || resolved == null) return;

    final preferenceController = ref.read(
      userPreferenceControllerProvider.notifier,
    );
    var preferences = ref.read(userPreferenceControllerProvider);

    if (!preferences.hasValidPreference) {
      await preferenceController.initializeGuestFromResolution(resolved);
      preferences = ref.read(userPreferenceControllerProvider);
    }

    final snapshot = preferences.snapshot;
    if (snapshot == null || !snapshot.isValid) {
      state = state.copyWith(
        didInitialize: true,
        error: 'A valid preference snapshot could not be restored.',
      );
      return;
    }

    final language = _languageFor(
      localization.languages,
      snapshot.language.canonicalId,
      snapshot.language.displayCode,
    );
    final country = _countryFor(
      localization.countries,
      snapshot.country.canonicalId,
      snapshot.country.displayCode,
    );
    final currency = _currencyFor(
      localization.currencies,
      snapshot.currency.canonicalId,
      snapshot.currency.displayCode,
    );

    if (language == null || country == null || currency == null) {
      state = state.copyWith(
        didInitialize: true,
        initialResolvedCountry: resolved.country,
        error:
            'The saved preference is no longer available in the backend '
            'locale catalog.',
      );
      return;
    }

    final needsCanonicalMigration =
        snapshot.language.canonicalId != language.canonicalId ||
        snapshot.country.canonicalId != country.canonicalId ||
        snapshot.currency.canonicalId != currency.canonicalId;
    if (needsCanonicalMigration && snapshot.isGuest) {
      final normalized = ActivePreferenceSnapshot(
        country: PreferenceSelection.fromCountry(
          country,
          source: snapshot.country.source,
        ),
        currency: PreferenceSelection.fromCurrency(
          currency,
          source: snapshot.currency.source,
        ),
        language: PreferenceSelection.fromLanguage(
          language,
          source: snapshot.language.source,
        ),
        authority: snapshot.authority,
        schemaVersion: localization.schemaVersion,
        savedAt: DateTime.now().toUtc(),
      );
      await preferenceController.replaceGuestSnapshot(normalized);
    }

    state = state.copyWith(
      language: language,
      country: country,
      currency: currency,
      initialResolvedCountry: resolved.country,
      didInitialize: true,
      clearError: true,
    );
  }

  void nextStep() {
    if (state.step >= 3) return;
    state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    if (state.step <= 0) return;
    state = state.copyWith(step: state.step - 1);
  }

  Future<void> selectLanguage(LanguageOption language) async {
    final previous = state.language;
    state = state.copyWith(language: language, clearError: true);
    try {
      await ref
          .read(userPreferenceControllerProvider.notifier)
          .updateLanguage(language);
    } catch (error) {
      if (previous != null) state = state.copyWith(language: previous);
      state = state.copyWith(error: error.toString());
      rethrow;
    }
  }

  Future<void> selectCountry(CountryOption country) async {
    final previous = state.country;
    state = state.copyWith(country: country, clearError: true);
    try {
      await ref
          .read(userPreferenceControllerProvider.notifier)
          .updateCountry(country);
    } catch (error) {
      if (previous != null) state = state.copyWith(country: previous);
      state = state.copyWith(error: error.toString());
      rethrow;
    }
  }

  Future<void> selectCurrency(CurrencyOption currency) async {
    final previous = state.currency;
    state = state.copyWith(currency: currency, clearError: true);
    try {
      await ref
          .read(userPreferenceControllerProvider.notifier)
          .updateCurrency(currency);
    } catch (error) {
      if (previous != null) state = state.copyWith(currency: previous);
      state = state.copyWith(error: error.toString());
      rethrow;
    }
  }

  Future<void> useCurrentLocation() async {
    final original = state.initialResolvedCountry;
    if (original == null || original.canonicalId == state.countryId) return;
    try {
      await selectCountry(original);
    } on Exception {
      // selectCountry already publishes the user-visible persistence error.
    }
  }

  CurrencyOption? countryCurrencyOption() {
    final countryCode = state.country?.displayCode;
    final mappedCurrency = LocalePresentationCatalog.currencyForCountryCode(
      countryCode,
    );
    if (mappedCurrency == null) return null;

    final currencies = ref.read(localizationControllerProvider).currencies;
    return _currencyFor(currencies, mappedCurrency, mappedCurrency);
  }

  Future<void> useCountryCurrency() async {
    final currency = countryCurrencyOption();
    if (currency == null || currency.canonicalId == state.currencyId) return;
    try {
      await selectCurrency(currency);
    } on Exception {
      // selectCurrency already publishes the user-visible persistence error.
    }
  }

  Future<void> finish() {
    final existing = _completionFuture;
    if (existing != null) return existing;

    final future = _finish();
    _completionFuture = future;
    return future.whenComplete(() {
      if (identical(_completionFuture, future)) _completionFuture = null;
    });
  }

  Future<void> _finish() async {
    if (!state.hasValidSelection) {
      state = state.copyWith(
        error: 'Select a valid language, country, and currency to continue.',
      );
      return;
    }

    state = state.copyWith(isCompleting: true, clearError: true);
    try {
      final preferences = ref.read(userPreferenceControllerProvider);
      if (!preferences.hasValidPreference ||
          preferences.languageId != state.languageId ||
          preferences.countryId != state.countryId ||
          preferences.currencyId != state.currencyId) {
        throw StateError('The active preference snapshot is not synchronized.');
      }

      await ref
          .read(appBootstrapControllerProvider.notifier)
          .completeOnboarding();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    } finally {
      state = state.copyWith(isCompleting: false);
    }
  }

  Future<void> skipForNow() async {
    final preferences = ref.read(userPreferenceControllerProvider);
    if (preferences.hasValidPreference && state.hasValidSelection) {
      await finish();
      return;
    }

    ref
        .read(appBootstrapControllerProvider.notifier)
        .deferOnboardingForSession();
  }

  LanguageOption? _languageFor(
    List<LanguageOption> items,
    String canonicalId,
    String displayCode,
  ) {
    for (final item in items) {
      if (item.canonicalId == canonicalId ||
          item.displayCode.toLowerCase() == displayCode.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  CountryOption? _countryFor(
    List<CountryOption> items,
    String canonicalId,
    String displayCode,
  ) {
    for (final item in items) {
      if (item.canonicalId == canonicalId ||
          item.displayCode.toUpperCase() == displayCode.toUpperCase()) {
        return item;
      }
    }
    return null;
  }

  CurrencyOption? _currencyFor(
    List<CurrencyOption> items,
    String canonicalId,
    String displayCode,
  ) {
    for (final item in items) {
      if (item.canonicalId == canonicalId ||
          item.displayCode.toUpperCase() == displayCode.toUpperCase()) {
        return item;
      }
    }
    return null;
  }
}
