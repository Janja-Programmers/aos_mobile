import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/localization/models/locale_presentation_catalog.dart';
import 'package:africaonlinestores/features/localization/models/supported_ui_languages.dart';

abstract class LocaleOption {
  const LocaleOption();

  String get canonicalId;
  String get displayCode;
  String get displayName;
  String? get backendFlag;
  String? get representativeFlag;
  String? get symbol;
  bool get enabled;
  bool get isDefault;

  String? get effectiveFlag {
    final backend = backendFlag?.trim();
    if (backend != null && backend.isNotEmpty) return backend;
    final representative = representativeFlag?.trim();
    return representative == null || representative.isEmpty
        ? null
        : representative;
  }

  String get searchableText => <String>[
    canonicalId,
    displayCode,
    displayName,
    symbol ?? '',
  ].join(' ').toLowerCase();
}

class CountryOption extends LocaleOption {
  const CountryOption({
    required this.canonicalId,
    required this.displayCode,
    required this.displayName,
    required this.backendFlag,
    this.enabled = true,
    this.isDefault = false,
  }) : super();

  factory CountryOption.fromJson(Map<String, dynamic> json) {
    final id = asString(json['id']).trim();
    final name = asString(json['name'], fallback: id).trim();
    if (id.isEmpty || name.isEmpty) {
      throw const FormatException(
        'Country is missing its canonical id or name.',
      );
    }

    return CountryOption(
      canonicalId: id,
      displayCode: asString(json['code']).trim().toUpperCase(),
      displayName: name,
      backendFlag: _nullableString(json['flag']),
      enabled: _boolValue(json['enabled'], fallback: true),
      isDefault: _boolValue(json['is_default']),
    );
  }

  @override
  final String canonicalId;
  @override
  final String displayCode;
  @override
  final String displayName;
  @override
  final String? backendFlag;
  @override
  final bool enabled;
  @override
  final bool isDefault;

  @override
  String? get representativeFlag => null;

  @override
  String? get symbol => null;
}

class LanguageOption extends LocaleOption {
  const LanguageOption({
    required this.canonicalId,
    required this.displayCode,
    required this.displayName,
    required this.backendFlag,
    required this.representativeFlag,
    this.enabled = true,
    this.isDefault = false,
  }) : super();

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    final id = asString(json['id']).trim();
    final code = normalizeUiLanguageCode(asString(json['code'], fallback: id));
    final name = asString(json['name'], fallback: id).trim();
    if (id.isEmpty || code.isEmpty || name.isEmpty) {
      throw const FormatException(
        'Language is missing its canonical id, code, or name.',
      );
    }

    return LanguageOption(
      canonicalId: id,
      displayCode: code,
      displayName: name,
      backendFlag: _nullableString(json['flag']),
      representativeFlag: LocalePresentationCatalog.languageRepresentativeFlag(
        code,
      ),
      enabled: _boolValue(json['enabled'], fallback: true),
      isDefault: _boolValue(json['is_default']),
    );
  }

  @override
  final String canonicalId;
  @override
  final String displayCode;
  @override
  final String displayName;
  @override
  final String? backendFlag;
  @override
  final String? representativeFlag;
  @override
  final bool enabled;
  @override
  final bool isDefault;

  bool get isRenderable => kSupportedUiLanguageCodes.contains(displayCode);

  @override
  String? get symbol => null;
}

class CurrencyOption extends LocaleOption {
  const CurrencyOption({
    required this.canonicalId,
    required this.displayCode,
    required this.displayName,
    required this.symbol,
    required this.representativeFlag,
    this.enabled = true,
    this.isDefault = false,
  }) : super();

  factory CurrencyOption.fromJson(Map<String, dynamic> json) {
    final id = asString(json['id']).trim();
    final code = asString(json['code'], fallback: id).trim().toUpperCase();
    final name = asString(json['name'], fallback: id).trim();
    if (id.isEmpty || code.isEmpty || name.isEmpty) {
      throw const FormatException(
        'Currency is missing its canonical id, code, or name.',
      );
    }

    return CurrencyOption(
      canonicalId: id,
      displayCode: code,
      displayName: name,
      symbol: _nullableString(json['symbol']),
      representativeFlag: LocalePresentationCatalog.currencyRepresentativeFlag(
        id,
      ),
      enabled: _boolValue(json['enabled'], fallback: true),
      isDefault: _boolValue(json['is_default']),
    );
  }

  @override
  final String canonicalId;
  @override
  final String displayCode;
  @override
  final String displayName;
  @override
  final String? symbol;
  @override
  final String? representativeFlag;
  @override
  final bool enabled;
  @override
  final bool isDefault;

  @override
  String? get backendFlag => null;
}

enum LocaleResolutionSource {
  request,
  geoIp,
  acceptLanguage,
  backendDefault,
  userPreference,
  unknown;

  static LocaleResolutionSource fromWire(String value) {
    return switch (value.trim().toLowerCase()) {
      'request' => LocaleResolutionSource.request,
      'geoip' => LocaleResolutionSource.geoIp,
      'accept_language' => LocaleResolutionSource.acceptLanguage,
      'default' => LocaleResolutionSource.backendDefault,
      'user_preference' => LocaleResolutionSource.userPreference,
      _ => LocaleResolutionSource.unknown,
    };
  }

  String get wireValue => switch (this) {
    LocaleResolutionSource.request => 'request',
    LocaleResolutionSource.geoIp => 'geoip',
    LocaleResolutionSource.acceptLanguage => 'accept_language',
    LocaleResolutionSource.backendDefault => 'default',
    LocaleResolutionSource.userPreference => 'user_preference',
    LocaleResolutionSource.unknown => 'unknown',
  };
}

class LocaleBundleDefaults {
  const LocaleBundleDefaults({
    required this.countryId,
    required this.currencyId,
    required this.languageId,
  });

  factory LocaleBundleDefaults.fromJson(Map<String, dynamic> json) {
    final country = asString(json['country']).trim();
    final currency = asString(json['currency']).trim();
    final language = asString(json['language']).trim();
    if (country.isEmpty || currency.isEmpty || language.isEmpty) {
      throw const FormatException('Locale bundle defaults are incomplete.');
    }

    return LocaleBundleDefaults(
      countryId: country,
      currencyId: currency,
      languageId: language,
    );
  }

  final String countryId;
  final String currencyId;
  final String languageId;
}

class ResolvedLocaleContext {
  const ResolvedLocaleContext({
    required this.country,
    required this.currency,
    required this.language,
    required this.countrySource,
    required this.currencySource,
    required this.languageSource,
    required this.schemaVersion,
  });

  factory ResolvedLocaleContext.fromJson(Map<String, dynamic> json) {
    final sources = asJsonMap(json['sources']);
    return ResolvedLocaleContext(
      country: CountryOption.fromJson(asJsonMap(json['country'])),
      currency: CurrencyOption.fromJson(asJsonMap(json['currency'])),
      language: LanguageOption.fromJson(asJsonMap(json['language'])),
      countrySource: LocaleResolutionSource.fromWire(
        asString(sources['country']),
      ),
      currencySource: LocaleResolutionSource.fromWire(
        asString(sources['currency']),
      ),
      languageSource: LocaleResolutionSource.fromWire(
        asString(sources['language']),
      ),
      schemaVersion: asString(json['schema_version']).trim(),
    );
  }

  final CountryOption country;
  final CurrencyOption currency;
  final LanguageOption language;
  final LocaleResolutionSource countrySource;
  final LocaleResolutionSource currencySource;
  final LocaleResolutionSource languageSource;
  final String schemaVersion;
}

String? _nullableString(Object? value) {
  final clean = asString(value).trim();
  return clean.isEmpty ? null : clean;
}

bool _boolValue(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final clean = asString(value).trim().toLowerCase();
  if (clean == 'true' || clean == '1') return true;
  if (clean == 'false' || clean == '0') return false;
  return fallback;
}
