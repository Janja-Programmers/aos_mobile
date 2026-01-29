import 'dart:convert';

/// User/device locale preferences used by the app.
///
/// - [countryCode] is ISO-3166 alpha-2 (e.g. KE)
/// - [languageCode] is a BCP-47-ish language code (e.g. en, sw)
/// - [currencyCode] is ISO-4217 (e.g. USD, KES)
class LocalePrefs {
  const LocalePrefs({
    required this.countryCode,
    required this.languageCode,
    required this.currencyCode,
    required this.timezone,
    this.languageOverridden = false,
    this.currencyOverridden = false,
  });

  final String countryCode;
  final String languageCode;
  final String currencyCode;
  final String timezone;

  final bool languageOverridden;
  final bool currencyOverridden;

  LocalePrefs copyWith({
    String? countryCode,
    String? languageCode,
    String? currencyCode,
    String? timezone,
    bool? languageOverridden,
    bool? currencyOverridden,
  }) {
    return LocalePrefs(
      countryCode: countryCode ?? this.countryCode,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      timezone: timezone ?? this.timezone,
      languageOverridden: languageOverridden ?? this.languageOverridden,
      currencyOverridden: currencyOverridden ?? this.currencyOverridden,
    );
  }

  Map<String, dynamic> toMap() => {
        'countryCode': countryCode,
        'languageCode': languageCode,
        'currencyCode': currencyCode,
        'timezone': timezone,
        'languageOverridden': languageOverridden,
        'currencyOverridden': currencyOverridden,
      };

  static LocalePrefs fromMap(Map<String, dynamic> map) {
    return LocalePrefs(
      countryCode: (map['countryCode'] ?? '').toString(),
      languageCode: (map['languageCode'] ?? 'en').toString(),
      currencyCode: (map['currencyCode'] ?? 'USD').toString(),
      timezone: (map['timezone'] ?? '').toString(),
      languageOverridden: map['languageOverridden'] == true,
      currencyOverridden: map['currencyOverridden'] == true,
    );
  }

  String toJson() => jsonEncode(toMap());

  static LocalePrefs fromJson(String json) {
    return fromMap(Map<String, dynamic>.from(jsonDecode(json) as Map));
  }
}
