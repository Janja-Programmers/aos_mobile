import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/localization/localization_state.dart';
import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/localization/data/system_locale.dart';

class LocalizationController extends AsyncNotifier<LocalizationState> {
  late final ApiClient _api;

  @override
  Future<LocalizationState> build() async {
    _api = ref.read(apiClientProvider);

    final response = await _api.dio.get(ApiEndpoints.getLocaleBundleEndpoint);
    final data = response.data["message"]["data"];

    final countries = List<Map<String, dynamic>>.from(data["countries"] ?? []);
    final languages = List<Map<String, dynamic>>.from(data["languages"] ?? []);
    final currencies = List<Map<String, dynamic>>.from(
      data["currencies"] ?? [],
    );

    final settings = data["settings"] as Map<String, dynamic>?;

    final serverDefaultCountry = settings?["default_country"] as String?;
    final serverDefaultLanguage = settings?["default_language"] as String?;
    final serverDefaultCurrency = settings?["default_currency"] as String?;

    // ---- device locale candidates
    final deviceLang = systemLanguageCode();
    final deviceCountry = systemCountryCode(); // nullable

    bool hasCountry(String? code) =>
        code != null && countries.any((c) => c["code"] == code);

    bool hasLanguage(String? code) =>
        code != null && languages.any((l) => l["code"] == code);

    bool hasCurrency(String? code) =>
        code != null && currencies.any((c) => c["code"] == code);

    // choose defaults: device -> server -> first -> null
    final defaultLanguage = hasLanguage(deviceLang)
        ? deviceLang
        : (hasLanguage(serverDefaultLanguage)
              ? serverDefaultLanguage
              : (languages.isNotEmpty
                    ? languages.first["code"] as String?
                    : null));

    final defaultCountry = hasCountry(deviceCountry)
        ? deviceCountry
        : (hasCountry(serverDefaultCountry)
              ? serverDefaultCountry
              : (countries.isNotEmpty
                    ? countries.first["code"] as String?
                    : null));

    // For currency: try to infer from chosen country if you want (see note below),
    // otherwise use device/server/first approach.
    final defaultCurrency = hasCurrency(serverDefaultCurrency)
        ? serverDefaultCurrency
        : (currencies.isNotEmpty ? currencies.first["code"] as String? : null);

    return LocalizationState(
      countries: countries,
      languages: languages,
      currencies: currencies,
      systemDefaultCountry: defaultCountry,
      systemDefaultLanguage: defaultLanguage,
      systemDefaultCurrency: defaultCurrency,
    );
  }

  bool isValidCountry(String code) {
    final current = state.value;
    return current?.countries.any((c) => c["code"] == code) ?? false;
  }

  bool isValidLanguage(String code) {
    final current = state.value;
    return current?.languages.any((l) => l["code"] == code) ?? false;
  }

  bool isValidCurrency(String code) {
    final current = state.value;
    return current?.currencies.any((c) => c["code"] == code) ?? false;
  }
}
