import 'dart:async';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/providers.dart' show apiClientProvider;
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/features/localization/models/localization_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final localizationControllerProvider =
    StateNotifierProvider<LocalizationController, LocalizationState>((ref) {
      final api = ref.watch(apiClientProvider);
      return LocalizationController(api);
    });

class LocalizationController extends StateNotifier<LocalizationState> {
  LocalizationController(this._api) : super(LocalizationState.initial()) {
    unawaited(load());
  }

  final ApiClient _api;
  Future<void>? _loadFuture;
  int _requestGeneration = 0;

  Future<void> load() {
    final existing = _loadFuture;
    if (existing != null) return existing;

    final generation = ++_requestGeneration;
    final future = _load(generation);
    _loadFuture = future;
    return future.whenComplete(() {
      if (identical(_loadFuture, future)) _loadFuture = null;
    });
  }

  Future<void> _load(int generation) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final bundleResponse = await _api.dio.get<Map<String, dynamic>>(
        ApiEndpoints.getLocaleBundleEndpoint,
      );
      final bundleData = _responseData(bundleResponse.data);

      final countries = asJsonMapList(bundleData['countries'])
          .map(CountryOption.fromJson)
          .where((item) => item.enabled)
          .toList(growable: false);
      final currencies = asJsonMapList(bundleData['currencies'])
          .map(CurrencyOption.fromJson)
          .where((item) => item.enabled)
          .toList(growable: false);
      final languages = asJsonMapList(bundleData['languages'])
          .map(LanguageOption.fromJson)
          .where((item) => item.enabled && item.isRenderable)
          .toList(growable: false);
      final defaults = LocaleBundleDefaults.fromJson(
        asJsonMap(bundleData['defaults']),
      );

      if (countries.isEmpty || currencies.isEmpty || languages.isEmpty) {
        throw const FormatException(
          'The backend locale bundle has no usable onboarding options.',
        );
      }

      final resolverResponse = await _api.dio.get<Map<String, dynamic>>(
        ApiEndpoints.resolveLocaleContextEndpoint,
      );
      final resolved = ResolvedLocaleContext.fromJson(
        _responseData(resolverResponse.data),
      );

      _validateResolvedContext(
        resolved,
        countries: countries,
        currencies: currencies,
        languages: languages,
      );

      if (generation != _requestGeneration) return;
      state = LocalizationState(
        countries: countries,
        languages: languages,
        currencies: currencies,
        defaults: defaults,
        resolvedContext: resolved,
        schemaVersion: asString(bundleData['schema_version']).trim(),
        isLoading: false,
      );
    } catch (error) {
      if (generation != _requestGeneration) return;
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Map<String, dynamic> _responseData(Map<String, dynamic>? rawResponse) {
    final body = asJsonMap(rawResponse);
    final message = asJsonMap(body['message']);
    if (message['ok'] != true) {
      final stableError = asString(message['error']).trim();
      final messageText = asString(message['message']).trim();
      throw StateError(
        stableError.isNotEmpty
            ? stableError
            : messageText.isNotEmpty
            ? messageText
            : 'Invalid localization response.',
      );
    }

    final data = asJsonMap(message['data']);
    if (data.isEmpty) {
      throw const FormatException('Localization response data is missing.');
    }
    return data;
  }

  void _validateResolvedContext(
    ResolvedLocaleContext resolved, {
    required List<CountryOption> countries,
    required List<CurrencyOption> currencies,
    required List<LanguageOption> languages,
  }) {
    final countryExists = countries.any(
      (item) => item.canonicalId == resolved.country.canonicalId,
    );
    final currencyExists = currencies.any(
      (item) => item.canonicalId == resolved.currency.canonicalId,
    );
    final languageExists = languages.any(
      (item) => item.canonicalId == resolved.language.canonicalId,
    );

    if (!countryExists || !currencyExists || !languageExists) {
      throw const FormatException(
        'Resolved locale context is not present in the usable locale bundle.',
      );
    }
  }
}
