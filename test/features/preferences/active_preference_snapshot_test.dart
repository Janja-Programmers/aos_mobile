import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/features/preferences/models/active_preference_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolved guest context round-trips as one coherent snapshot', () {
    final context = ResolvedLocaleContext.fromJson(<String, dynamic>{
      'schema_version': '1.1',
      'country': <String, dynamic>{
        'id': 'Kenya',
        'name': 'Kenya',
        'code': 'KE',
        'flag': '🇰🇪',
      },
      'currency': <String, dynamic>{
        'id': 'KES',
        'code': 'KES',
        'name': 'Kenyan Shilling',
        'symbol': 'KSh',
      },
      'language': <String, dynamic>{
        'id': 'en',
        'code': 'en',
        'name': 'English',
      },
      'sources': <String, dynamic>{
        'country': 'geoip',
        'currency': 'default',
        'language': 'accept_language',
      },
    });

    final snapshot = ActivePreferenceSnapshot.fromResolvedContext(context);
    final restored = ActivePreferenceSnapshot.fromJson(snapshot.toJson());

    expect(restored.isValid, isTrue);
    expect(restored.country.canonicalId, 'Kenya');
    expect(restored.currency.canonicalId, 'KES');
    expect(restored.language.canonicalId, 'en');
    expect(restored.country.source, LocaleResolutionSource.geoIp);
    expect(restored.authority, PreferenceAuthority.guestResolution);
  });

  test('server preferences use canonical id before display code and name', () {
    final snapshot = ActivePreferenceSnapshot.fromServerPreferences(
      <String, dynamic>{
        'country': <String, dynamic>{
          'id': 'Kenya',
          'name': 'Kenya',
          'code': 'KE',
        },
        'currency': <String, dynamic>{
          'id': 'KES',
          'code': 'KES',
          'name': 'Kenyan Shilling',
        },
        'language': <String, dynamic>{
          'id': 'en',
          'code': 'en',
          'name': 'English',
        },
      },
      authority: PreferenceAuthority.authenticatedLogin,
    );

    expect(snapshot.country.canonicalId, 'Kenya');
    expect(snapshot.country.displayCode, 'KE');
    expect(snapshot.authority, PreferenceAuthority.authenticatedLogin);
  });
}
