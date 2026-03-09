import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/providers.dart' show apiClientProvider;

import 'package:africaonlinestores/features/localization/models/localization_state.dart';
import 'package:flutter_riverpod/legacy.dart';

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

      /// Countries
      final countries = List<Map<String, dynamic>>.from(data["countries"] ?? [])
          .map((c) {
            return {
              "name": (c["name"] ?? "").toString(),
              "code": (c["code"] ?? "").toString().toUpperCase(),
            };
          })
          .toList();

      /// Languages
      final languages = List<Map<String, dynamic>>.from(data["languages"] ?? [])
          .map((l) {
            return {
              "name": (l["name"] ?? "").toString(),
              "code": (l["code"] ?? "").toString().toLowerCase(),
            };
          })
          .toList();

      /// Currencies
      final rawCurrencies = List<Map<String, dynamic>>.from(
        data["currencies"] ?? [],
      );

      final currencies = rawCurrencies.map((c) {
        final code = (c["name"] ?? "").toString().toUpperCase();
        final symbol = (c["symbol"] ?? "").toString().trim();

        final display = symbol.isEmpty ? code : "$code ($symbol)";

        return <String, dynamic>{
          "code": code,
          "symbol": symbol,
          "display": display,
        };
      }).toList();

      state = state.copyWith(
        countries: countries,
        languages: languages,
        currencies: currencies,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool isValidCountry(String code) {
    return state.countries.any(
      (c) => (c["code"] ?? "").toString().toUpperCase() == code.toUpperCase(),
    );
  }

  bool isValidLanguage(String code) {
    return state.languages.any(
      (l) => (l["code"] ?? "").toString().toLowerCase() == code.toLowerCase(),
    );
  }

  bool isValidCurrency(String code) {
    return state.currencies.any(
      (c) => (c["code"] ?? "").toString().toUpperCase() == code.toUpperCase(),
    );
  }
}
