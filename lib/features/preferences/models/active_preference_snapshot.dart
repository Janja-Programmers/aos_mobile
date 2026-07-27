import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';

const int kActivePreferenceSnapshotVersion = 1;

enum PreferenceAuthority {
  guestResolution,
  guestManual,
  authenticatedLogin,
  authenticatedMe,
  authenticatedUpdate,
  offlineRestoration,
  legacyMigration,
  unknown;

  static PreferenceAuthority fromWire(String value) {
    return switch (value.trim()) {
      'guestResolution' => PreferenceAuthority.guestResolution,
      'guestManual' => PreferenceAuthority.guestManual,
      'authenticatedLogin' => PreferenceAuthority.authenticatedLogin,
      'authenticatedMe' => PreferenceAuthority.authenticatedMe,
      'authenticatedUpdate' => PreferenceAuthority.authenticatedUpdate,
      'offlineRestoration' => PreferenceAuthority.offlineRestoration,
      'legacyMigration' => PreferenceAuthority.legacyMigration,
      _ => PreferenceAuthority.unknown,
    };
  }
}

class PreferenceSelection {
  const PreferenceSelection({
    required this.canonicalId,
    required this.displayCode,
    required this.displayName,
    required this.backendFlag,
    required this.representativeFlag,
    required this.symbol,
    required this.enabled,
    required this.isDefault,
    required this.source,
  });

  factory PreferenceSelection.fromCountry(
    CountryOption option, {
    required LocaleResolutionSource source,
  }) {
    return PreferenceSelection(
      canonicalId: option.canonicalId,
      displayCode: option.displayCode,
      displayName: option.displayName,
      backendFlag: option.backendFlag,
      representativeFlag: option.representativeFlag,
      symbol: option.symbol,
      enabled: option.enabled,
      isDefault: option.isDefault,
      source: source,
    );
  }

  factory PreferenceSelection.fromLanguage(
    LanguageOption option, {
    required LocaleResolutionSource source,
  }) {
    return PreferenceSelection(
      canonicalId: option.canonicalId,
      displayCode: option.displayCode,
      displayName: option.displayName,
      backendFlag: option.backendFlag,
      representativeFlag: option.representativeFlag,
      symbol: option.symbol,
      enabled: option.enabled,
      isDefault: option.isDefault,
      source: source,
    );
  }

  factory PreferenceSelection.fromCurrency(
    CurrencyOption option, {
    required LocaleResolutionSource source,
  }) {
    return PreferenceSelection(
      canonicalId: option.canonicalId,
      displayCode: option.displayCode,
      displayName: option.displayName,
      backendFlag: option.backendFlag,
      representativeFlag: option.representativeFlag,
      symbol: option.symbol,
      enabled: option.enabled,
      isDefault: option.isDefault,
      source: source,
    );
  }

  factory PreferenceSelection.fromJson(Map<String, dynamic> json) {
    return PreferenceSelection(
      canonicalId: asString(json['canonical_id']).trim(),
      displayCode: asString(json['display_code']).trim(),
      displayName: asString(json['display_name']).trim(),
      backendFlag: _nullableString(json['backend_flag']),
      representativeFlag: _nullableString(json['representative_flag']),
      symbol: _nullableString(json['symbol']),
      enabled: json['enabled'] != false,
      isDefault: json['is_default'] == true,
      source: LocaleResolutionSource.fromWire(asString(json['source'])),
    );
  }

  factory PreferenceSelection.legacy(String canonicalId) {
    final clean = canonicalId.trim();
    return PreferenceSelection(
      canonicalId: clean,
      displayCode: clean,
      displayName: clean,
      backendFlag: null,
      representativeFlag: null,
      symbol: null,
      enabled: true,
      isDefault: false,
      source: LocaleResolutionSource.unknown,
    );
  }

  final String canonicalId;
  final String displayCode;
  final String displayName;
  final String? backendFlag;
  final String? representativeFlag;
  final String? symbol;
  final bool enabled;
  final bool isDefault;
  final LocaleResolutionSource source;

  bool get isValid => canonicalId.trim().isNotEmpty && enabled;

  String? get effectiveFlag {
    final backend = backendFlag?.trim();
    if (backend != null && backend.isNotEmpty) return backend;
    final representative = representativeFlag?.trim();
    return representative == null || representative.isEmpty
        ? null
        : representative;
  }

  PreferenceSelection copyWith({
    String? canonicalId,
    String? displayCode,
    String? displayName,
    String? backendFlag,
    String? representativeFlag,
    String? symbol,
    bool? enabled,
    bool? isDefault,
    LocaleResolutionSource? source,
  }) {
    return PreferenceSelection(
      canonicalId: canonicalId ?? this.canonicalId,
      displayCode: displayCode ?? this.displayCode,
      displayName: displayName ?? this.displayName,
      backendFlag: backendFlag ?? this.backendFlag,
      representativeFlag: representativeFlag ?? this.representativeFlag,
      symbol: symbol ?? this.symbol,
      enabled: enabled ?? this.enabled,
      isDefault: isDefault ?? this.isDefault,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'canonical_id': canonicalId,
      'display_code': displayCode,
      'display_name': displayName,
      'backend_flag': backendFlag,
      'representative_flag': representativeFlag,
      'symbol': symbol,
      'enabled': enabled,
      'is_default': isDefault,
      'source': source.wireValue,
    };
  }
}

class ActivePreferenceSnapshot {
  const ActivePreferenceSnapshot({
    required this.country,
    required this.currency,
    required this.language,
    required this.authority,
    required this.schemaVersion,
    required this.savedAt,
    this.version = kActivePreferenceSnapshotVersion,
  });

  factory ActivePreferenceSnapshot.fromResolvedContext(
    ResolvedLocaleContext context,
  ) {
    return ActivePreferenceSnapshot(
      country: PreferenceSelection.fromCountry(
        context.country,
        source: context.countrySource,
      ),
      currency: PreferenceSelection.fromCurrency(
        context.currency,
        source: context.currencySource,
      ),
      language: PreferenceSelection.fromLanguage(
        context.language,
        source: context.languageSource,
      ),
      authority: PreferenceAuthority.guestResolution,
      schemaVersion: context.schemaVersion,
      savedAt: DateTime.now().toUtc(),
    );
  }

  factory ActivePreferenceSnapshot.fromServerPreferences(
    Map<String, dynamic> json, {
    required PreferenceAuthority authority,
  }) {
    final country = CountryOption.fromJson(asJsonMap(json['country']));
    final currency = CurrencyOption.fromJson(asJsonMap(json['currency']));
    final language = LanguageOption.fromJson(asJsonMap(json['language']));
    if (!language.isRenderable) {
      throw const FormatException(
        'The authenticated language is not supported by this app build.',
      );
    }

    return ActivePreferenceSnapshot(
      country: PreferenceSelection.fromCountry(
        country,
        source: LocaleResolutionSource.userPreference,
      ),
      currency: PreferenceSelection.fromCurrency(
        currency,
        source: LocaleResolutionSource.userPreference,
      ),
      language: PreferenceSelection.fromLanguage(
        language,
        source: LocaleResolutionSource.userPreference,
      ),
      authority: authority,
      schemaVersion: asString(json['schema_version']).trim(),
      savedAt: DateTime.now().toUtc(),
    );
  }

  factory ActivePreferenceSnapshot.fromJson(Map<String, dynamic> json) {
    final version = int.tryParse(asString(json['version'])) ?? 0;
    if (version != kActivePreferenceSnapshotVersion) {
      throw FormatException(
        'Unsupported preference snapshot version: $version',
      );
    }

    return ActivePreferenceSnapshot(
      country: PreferenceSelection.fromJson(asJsonMap(json['country'])),
      currency: PreferenceSelection.fromJson(asJsonMap(json['currency'])),
      language: PreferenceSelection.fromJson(asJsonMap(json['language'])),
      authority: PreferenceAuthority.fromWire(asString(json['authority'])),
      schemaVersion: asString(json['schema_version']).trim(),
      savedAt:
          DateTime.tryParse(asString(json['saved_at']))?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      version: version,
    );
  }

  factory ActivePreferenceSnapshot.legacy({
    required String country,
    required String currency,
    required String language,
  }) {
    return ActivePreferenceSnapshot(
      country: PreferenceSelection.legacy(country),
      currency: PreferenceSelection.legacy(currency),
      language: PreferenceSelection.legacy(language),
      authority: PreferenceAuthority.legacyMigration,
      schemaVersion: '',
      savedAt: DateTime.now().toUtc(),
    );
  }

  final int version;
  final PreferenceSelection country;
  final PreferenceSelection currency;
  final PreferenceSelection language;
  final PreferenceAuthority authority;
  final String schemaVersion;
  final DateTime savedAt;

  bool get isValid =>
      country.isValid &&
      currency.isValid &&
      language.isValid &&
      authority != PreferenceAuthority.unknown;

  bool get isGuest =>
      authority == PreferenceAuthority.guestResolution ||
      authority == PreferenceAuthority.guestManual ||
      authority == PreferenceAuthority.offlineRestoration ||
      authority == PreferenceAuthority.legacyMigration;

  ActivePreferenceSnapshot copyWith({
    PreferenceSelection? country,
    PreferenceSelection? currency,
    PreferenceSelection? language,
    PreferenceAuthority? authority,
    String? schemaVersion,
    DateTime? savedAt,
  }) {
    return ActivePreferenceSnapshot(
      country: country ?? this.country,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      authority: authority ?? this.authority,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      savedAt: savedAt ?? DateTime.now().toUtc(),
      version: version,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'country': country.toJson(),
      'currency': currency.toJson(),
      'language': language.toJson(),
      'authority': authority.name,
      'schema_version': schemaVersion,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}

String? _nullableString(Object? value) {
  final clean = asString(value).trim();
  return clean.isEmpty ? null : clean;
}
