import 'package:africaonlinestores/features/localization/models/locale_presentation_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalePresentationCatalog', () {
    test('provides representative flags for supported UI languages', () {
      for (final language in <String>['en', 'ar', 'fr', 'sw', 'zh']) {
        expect(
          LocalePresentationCatalog.languageRepresentativeFlag(language),
          isNotEmpty,
          reason: language,
        );
      }
    });

    test('provides representative currency flags without changing IDs', () {
      expect(
        LocalePresentationCatalog.currencyRepresentativeCountryCode('KES'),
        'KE',
      );
      expect(
        LocalePresentationCatalog.currencyRepresentativeFlag('USD'),
        '🇺🇸',
      );
      expect(
        LocalePresentationCatalog.currencyRepresentativeFlag('UNKNOWN'),
        isNull,
      );
    });

    test('maps country currency only for explicit associations', () {
      expect(LocalePresentationCatalog.currencyForCountryCode('KE'), 'KES');
      expect(LocalePresentationCatalog.currencyForCountryCode('US'), 'USD');
      expect(LocalePresentationCatalog.currencyForCountryCode('XX'), isNull);
      expect(LocalePresentationCatalog.currencyForCountryCode(null), isNull);
    });
  });
}
