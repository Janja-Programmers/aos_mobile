import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/providers.dart' show apiClientProvider;
import 'package:africaonlinestores/core/utils/json_utils.dart';
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
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.dio.get<Map<String, dynamic>>(
        ApiEndpoints.getLocaleBundleEndpoint,
      );

      final body = asJsonMap(response.data);
      final message = asJsonMap(body['message']);
      final data = asJsonMap(message['data']);

      final countries = asJsonMapList(data['countries']).map((c) {
        return {
          'name': (c['name'] ?? '').toString(),
          'code': (c['code'] ?? '').toString().toUpperCase(),
        };
      }).toList();

      final languages = asJsonMapList(data['languages']).map((l) {
        return {
          'name': (l['name'] ?? '').toString(),
          'code': (l['code'] ?? '').toString().toLowerCase(),
        };
      }).toList();

      final rawCurrencies = asJsonMapList(data['currencies']);

      final currencies = rawCurrencies.map((c) {
        final code = (c['name'] ?? '').toString().toUpperCase();
        final symbol = (c['symbol'] ?? '').toString().trim();
        final display = symbol.isEmpty ? code : '$code ($symbol)';

        return <String, dynamic>{
          'code': code,
          'symbol': symbol,
          'display': display,
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
}
