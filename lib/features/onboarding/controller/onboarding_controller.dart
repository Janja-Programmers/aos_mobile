import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';

import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/onboarding/models/onboarding_state.dart';
import 'package:africaonlinestores/core/utils/device_locale.dart';

import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
      return OnboardingController(ref);
    });

class OnboardingController extends StateNotifier<OnboardingState> {
  final Ref ref;

  OnboardingController(this.ref) : super(OnboardingState.initial());

  void initializeDefaultsIfNeeded() {
    if (state.didInitDefaults) return;

    final localization = ref.read(localizationControllerProvider);

    if (localization.isLoading || localization.error != null) {
      return;
    }

    final prefs = ref.read(userPreferenceControllerProvider);

    /// ---------- LANGUAGE RESOLUTION ----------
    final supportedLanguages = localization.languages;

    final savedLang = prefs.languageCode.trim().toLowerCase();
    final deviceLang = DeviceLocale.languageCode();

    bool hasLanguage(String? code) {
      if (code == null || code.isEmpty) return false;

      return supportedLanguages.any(
        (l) => (l['code'] ?? '').toString().toLowerCase() == code,
      );
    }

    final resolvedLang = hasLanguage(savedLang)
        ? savedLang
        : hasLanguage(deviceLang)
        ? deviceLang
        : (supportedLanguages.isNotEmpty
              ? (supportedLanguages.first['code'] ?? '')
                    .toString()
                    .toLowerCase()
              : null);

    final nextLanguage = state.languageCode ?? resolvedLang;

    /// ---------- COUNTRY RESOLUTION ----------
    final supportedCountries = localization.countries;

    final savedCountry = prefs.countryCode.trim().toUpperCase();
    final deviceCountry = DeviceLocale.countryCode()?.toUpperCase();

    bool hasCountry(String? code) {
      if (code == null || code.isEmpty) return false;

      final normalized = code.length >= 2
          ? code.substring(0, 2).toUpperCase()
          : code;

      return supportedCountries.any((c) {
        final cCode = (c['code'] ?? '').toString().toUpperCase();
        return cCode.startsWith(normalized);
      });
    }

    final resolvedCountry = hasCountry(savedCountry)
        ? savedCountry
        : hasCountry(deviceCountry)
        ? deviceCountry
        : (supportedCountries.isNotEmpty
              ? (supportedCountries.first['code'] ?? '')
                    .toString()
                    .toUpperCase()
              : null);

    /// ---------- CURRENCY RESOLUTION ----------
    final savedCurrency = prefs.currencyCode.trim().toUpperCase();

    final resolvedCurrency = savedCurrency.isNotEmpty ? savedCurrency : 'USD';

    state = state.copyWith(
      languageCode: nextLanguage,
      countryCode: state.countryCode ?? resolvedCountry,
      currencyCode: state.currencyCode ?? resolvedCurrency,
      didInitDefaults: true,
    );
  }

  void initializeOfflineDefaultsIfNeeded() {
    if (state.didInitDefaults) return;

    final prefs = ref.read(userPreferenceControllerProvider);

    final savedLang = prefs.languageCode.trim().toLowerCase();
    final savedCountry = prefs.countryCode.trim().toUpperCase();
    final savedCurrency = prefs.currencyCode.trim().toUpperCase();

    final deviceLang = DeviceLocale.languageCode();
    final deviceCountry = DeviceLocale.countryCode()?.toUpperCase();

    state = state.copyWith(
      languageCode:
          state.languageCode ??
          (savedLang.isNotEmpty ? savedLang : deviceLang ?? 'en'),
      countryCode:
          state.countryCode ??
          (savedCountry.isNotEmpty ? savedCountry : deviceCountry ?? 'KE'),
      currencyCode:
          state.currencyCode ??
          (savedCurrency.isNotEmpty ? savedCurrency : 'KSH'),
      didInitDefaults: true,
    );
  }

  void nextStep() {
    state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    state = state.copyWith(step: state.step - 1);
  }

  /// Called by UI when user changes language
  void setLanguageCode(String code) {
    state = state.copyWith(languageCode: code.trim().toLowerCase());
  }

  void setCountryCode(String code) {
    state = state.copyWith(countryCode: code.trim().toUpperCase());
  }

  void setCurrencyCode(String code) {
    state = state.copyWith(currencyCode: code.trim().toUpperCase());
  }

  Future<void> finish() async {
    final prefs = ref.read(userPreferenceControllerProvider.notifier);

    if (state.languageCode != null) {
      await prefs.updateLanguageCode(state.languageCode!);
    }

    if (state.countryCode != null) {
      await prefs.updateCountryCode(state.countryCode!);
    }

    if (state.currencyCode != null) {
      await prefs.updateCurrencyCode(state.currencyCode!);
    }

    await ref
        .read(appBootstrapControllerProvider.notifier)
        .completeOnboarding();
  }
}
