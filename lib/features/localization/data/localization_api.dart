import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/localization/domain/locale_bundle.dart';

class LocalizationApi {
  LocalizationApi(this._client);
  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Either<Failure, LocaleBundle>> getLocaleBundle() async {
    try {
      final res = await _dio.get(ApiEndpoints.getLocaleBundleEndpoint);
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final p = unwrapped.rightOrNull!;

      // Backend returns: {ok, data:{settings:{...}, countries:[], languages:[], currencies:[]}}
      final data = (p['data'] is Map)
          ? Map<String, dynamic>.from(p['data'] as Map)
          : <String, dynamic>{};

      final settings = (data['settings'] is Map)
          ? Map<String, dynamic>.from(data['settings'] as Map)
          : <String, dynamic>{};

      final baseCurrencyCode = (settings['base_currency'] ?? 'USD').toString();
      final defaultLanguageCode = (settings['default_language'] ?? 'en')
          .toString();
      final defaultCountryCode = (settings['default_country'] ?? 'KE')
          .toString();

      final countries = _parseOptions(
        data['countries'],
        codeKey: 'code',
        labelKey: 'name',
      );
      final languages = _parseOptions(
        data['languages'],
        codeKey: 'code',
        labelKey: 'name',
      );
      final currencies = _parseOptions(
        data['currencies'],
        codeKey: 'symbol',
        labelKey: 'code',
      );

      return Either.right(
        LocaleBundle(
          countries: countries,
          languages: languages,
          currencies: currencies,
          baseCurrencyCode: baseCurrencyCode,
          defaultLanguageCode: defaultLanguageCode,
          defaultCountryCode: defaultCountryCode,
        ),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load locale configuration.'));
    }
  }

  Future<Either<Failure, UserPreferencesDto?>> getMyPreferences() async {
    try {
      final res = await _dio.get(ApiEndpoints.getMyPreferencesEndpoint);
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final p = unwrapped.rightOrNull!;
      final data = (p['data'] is Map)
          ? Map<String, dynamic>.from(p['data'] as Map)
          : <String, dynamic>{};
      final m = Map<String, dynamic>.from(data);
      return Either.right(_prefsFromMap(m));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load your preferences.'));
    }
  }

  Future<Either<Failure, UserPreferencesDto>> updatePreferences({
    required String countryCode,
    required String languageCode,
    required String currencyCode,
    required String timezone,
    required bool overrideLanguage,
    required bool overrideCurrency,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.updatePreferencesEndpoint,
        data: {
          'country': countryCode,
          'language': languageCode,
          'currency': currencyCode,
          'timezone': timezone,
          'override_language': overrideLanguage,
          'override_currency': overrideCurrency,
        },
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final p = unwrapped.rightOrNull!;
      final data = (p['data'] is Map)
          ? Map<String, dynamic>.from(p['data'] as Map)
          : <String, dynamic>{};
      final prefs = (data['preferences'] is Map)
          ? Map<String, dynamic>.from(data['preferences'] as Map)
          : <String, dynamic>{};
      return Either.right(_prefsFromMap(prefs));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update preferences.'));
    }
  }

  static List<LocaleOption> _parseOptions(
    dynamic raw, {
    required String codeKey,
    required String labelKey,
  }) {
    final out = <LocaleOption>[];
    final seen = <String>{};

    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);

        final code = (m[codeKey] ?? '').toString().trim();
        if (code.isEmpty) continue;

        // Prefer provided labelKey, but fall back to common keys.
        final label =
            ((m[labelKey] ?? m['name'] ?? m['label'] ?? m['code']) ?? '')
                .toString()
                .trim();
        if (label.isEmpty) continue;

        if (seen.contains(code)) continue; // ✅ de-dupe by code
        seen.add(code);

        out.add(LocaleOption(code: code, label: label));
      }
    }

    return out;
  }

  static UserPreferencesDto _prefsFromMap(Map<String, dynamic> m) {
    final country = (m['country'] is Map)
        ? Map<String, dynamic>.from(m['country'])
        : const <String, dynamic>{};
    final language = (m['language'] is Map)
        ? Map<String, dynamic>.from(m['language'])
        : const <String, dynamic>{};
    final currency = (m['currency'] is Map)
        ? Map<String, dynamic>.from(m['currency'])
        : const <String, dynamic>{};
    final overrides = (m['overrides'] is Map)
        ? Map<String, dynamic>.from(m['overrides'])
        : const <String, dynamic>{};

    return UserPreferencesDto(
      countryCode: (country['code'] ?? '').toString(),
      languageCode: (language['code'] ?? 'en').toString(),
      currencyCode: (currency['code'] ?? 'KES').toString(),
      timezone: (m['timezone'] ?? '').toString(),

      languageOverridden: overrides['language'] == true,
      currencyOverridden: overrides['currency'] == true,
    );
  }
}
