import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/localization/localization_state.dart';
import 'package:africaonlinestores/core/providers.dart';

class LocalizationController extends AsyncNotifier<LocalizationState> {
  late final ApiClient _api;

  @override
  Future<LocalizationState> build() async {
    _api = ref.read(apiClientProvider);

    final response = await _api.dio.get(ApiEndpoints.getLocaleBundleEndpoint);

    final data = response.data["message"]["data"];

    return LocalizationState(
      countries: List<Map<String, dynamic>>.from(data["countries"] ?? []),
      languages: List<Map<String, dynamic>>.from(data["languages"] ?? []),
      currencies: List<Map<String, dynamic>>.from(data["currencies"] ?? []),
      systemDefaultCountry: data["settings"]?["default_country"],
      systemDefaultLanguage: data["settings"]?["default_language"],
      systemDefaultCurrency: data["settings"]?["default_currency"],
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
