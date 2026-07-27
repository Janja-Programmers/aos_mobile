import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('localization models', () {
    test('preserves canonical IDs separately from display metadata', () {
      final country = CountryOption.fromJson(<String, dynamic>{
        'id': 'Kenya',
        'name': 'Kenya',
        'code': 'KE',
        'flag': '🇰🇪',
      });
      final currency = CurrencyOption.fromJson(<String, dynamic>{
        'id': 'USD',
        'code': 'USD',
        'name': 'US Dollar',
        'symbol': r'$',
        'enabled': true,
      });
      final language = LanguageOption.fromJson(<String, dynamic>{
        'id': 'en',
        'code': 'en-US',
        'name': 'English',
        'flag': null,
        'enabled': true,
      });

      expect(country.canonicalId, 'Kenya');
      expect(country.displayCode, 'KE');
      expect(country.effectiveFlag, '🇰🇪');
      expect(currency.canonicalId, 'USD');
      expect(currency.displayName, 'US Dollar');
      expect(currency.symbol, r'$');
      expect(language.canonicalId, 'en');
      expect(language.displayCode, 'en');
      expect(language.isRenderable, isTrue);
      expect(language.effectiveFlag, isNotEmpty);
    });

    test('does not claim an unsupported Flutter language is renderable', () {
      final language = LanguageOption.fromJson(<String, dynamic>{
        'id': 'de',
        'code': 'de',
        'name': 'Deutsch',
        'enabled': true,
      });

      expect(language.isRenderable, isFalse);
    });

    test('rejects malformed canonical data', () {
      expect(
        () => CurrencyOption.fromJson(<String, dynamic>{
          'name': 'US Dollar',
          'symbol': r'$',
        }),
        throwsFormatException,
      );
    });

    test('parses resolution sources without throwing on unknown values', () {
      expect(
        LocaleResolutionSource.fromWire('geoip'),
        LocaleResolutionSource.geoIp,
      );
      expect(
        LocaleResolutionSource.fromWire('future_source'),
        LocaleResolutionSource.unknown,
      );
    });
  });
}
