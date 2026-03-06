import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/providers.dart ' show apiClientProvider;
import 'package:africaonlinestores/features/localization/localization_state.dart';

final localizationControllerProvider =
    StateNotifierProvider<LocalizationController, LocalizationState>((ref) {
      final api = ref.watch(apiClientProvider);
      return LocalizationController(api);
    });

class LocalizationController extends StateNotifier<LocalizationState> {
  final ApiClient _api;

  LocalizationController(this._api) : super(LocalizationState.initial()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.getLocaleBundleEndpoint);
      final data = response.data["message"]["data"];

      final countries = List<Map<String, dynamic>>.from(
        data["countries"] ?? [],
      );

      final languages = List<Map<String, dynamic>>.from(
        data["languages"] ?? [],
      );

      final rawCurrencies = List<Map<String, dynamic>>.from(
        data["currencies"] ?? [],
      );

      /// Normalize currencies for picker compatibility
      final currencies = rawCurrencies.map((c) {
        final code = (c["code"] ?? "").toString().toUpperCase();
        final symbol = (c["symbol"] ?? "").toString().trim();

        final display = symbol.isEmpty ? code : "$code ($symbol)";

        return <String, dynamic>{
          "code": code,
          "name": display,
          "symbol": symbol,
        };
      }).toList();

      state = state.copyWith(
        countries: countries,
        languages: languages,
        currencies: currencies,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool isValidCountry(String code) {
    return state.countries.any((c) => c["code"] == code);
  }

  bool isValidLanguage(String code) {
    return state.languages.any((l) => l["code"] == code);
  }

  bool isValidCurrency(String code) {
    return state.currencies.any((c) => c["code"] == code);
  }
}
