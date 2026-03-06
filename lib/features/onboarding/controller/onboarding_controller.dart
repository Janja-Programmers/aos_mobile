import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';

import 'package:africaonlinestores/features/localization/localization_controller.dart';
import 'package:africaonlinestores/core/utils/device_locale.dart';

import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/onboarding/models/onboarding_state.dart';

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

    final supportedLanguages = localization.languages;
    final savedLang = prefs.language.trim().toLowerCase();
    final deviceLang = DeviceLocale.languageCode();

    bool hasLanguage(String? code) {
      if (code == null || code.isEmpty) return false;
      return supportedLanguages.any(
        (l) => (l['code'] ?? '').toString().trim().toLowerCase() == code,
      );
    }

    final resolvedLang = hasLanguage(savedLang)
        ? savedLang
        : (hasLanguage(deviceLang)
              ? deviceLang
              : (supportedLanguages.isNotEmpty
                    ? (supportedLanguages.first['code'] ?? '')
                          .toString()
                          .trim()
                          .toLowerCase()
                    : null));

    // Only set if user hasn't picked anything yet.
    final nextLanguage = state.language ?? resolvedLang;

    // ---------- COUNTRY RESOLUTION ----------
    final supportedCountries = localization.countries;
    final savedCountry = prefs.country.trim().toUpperCase();
    final deviceCountry = DeviceLocale.countryCode()?.toUpperCase();

    bool hasCountry(String? code) {
      if (code == null || code.isEmpty) return false;
      final normalized = code.substring(0, 2);
      return supportedCountries.any((c) {
        final cCode = (c['code'] ?? '').toString().toUpperCase();
        return cCode.startsWith(normalized);
      });
    }

    final resolvedCountry = hasCountry(savedCountry)
        ? savedCountry
        : (hasCountry(deviceCountry)
              ? deviceCountry
              : (supportedCountries.isNotEmpty
                    ? (supportedCountries.first['code'] ?? '')
                          .toString()
                          .toUpperCase()
                    : null));

    // ---------- CURRENCY RESOLUTION ----------
    String? currencyFromCountry(String? countryCode) {
      if (countryCode == null) return null;

      final match = supportedCountries.firstWhere(
        (c) => (c['code'] ?? '').toString().toUpperCase() == countryCode,
        orElse: () => {},
      );

      return match.isNotEmpty
          ? (match['currency'] ?? '').toString().toUpperCase()
          : null;
    }

    final resolvedCurrency = currencyFromCountry(resolvedCountry);

    state = state.copyWith(
      language: nextLanguage,
      country: state.country ?? resolvedCountry,
      currency: state.currency ?? resolvedCurrency,
      didInitDefaults: true,
    );
  }

  void nextStep() => state = state.copyWith(step: state.step + 1);
  void previousStep() => state = state.copyWith(step: state.step - 1);

  /// Called by UI when user changes language in picker
  void setLanguage(String code) {
    state = state.copyWith(language: code.trim().toLowerCase());
  }

  void setCountry(String code) {
    state = state.copyWith(country: code);
  }

  void setCurrency(String code) {
    state = state.copyWith(currency: code);
  }

  Future<void> finish() async {
    final prefs = ref.read(userPreferenceControllerProvider.notifier);

    if (state.language != null) {
      await prefs.updateLanguage(state.language!);
    }

    if (state.country != null) {
      await prefs.updateCountry(state.country!);
    }

    if (state.currency != null) {
      await prefs.updateCurrency(state.currency!);
    }

    await ref
        .read(appBootstrapControllerProvider.notifier)
        .completeOnboarding();
  }
}
