import 'dart:convert';

import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/features/preferences/models/active_preference_snapshot.dart';
import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'persists country, currency, and language in one snapshot value',
    () async {
      final shared = await SharedPreferences.getInstance();
      final storage = OnboardingStorage(shared);
      final snapshot = ActivePreferenceSnapshot.legacy(
        country: 'Kenya',
        currency: 'KES',
        language: 'en',
      );

      await storage.savePreferences(UserPreferenceState(snapshot: snapshot));

      final keys = shared.getKeys();
      expect(keys, contains('aos_active_preference_snapshot_v1'));
      expect(keys, isNot(contains('pref_country_code')));
      final raw = shared.getString('aos_active_preference_snapshot_v1');
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['country'], isA<Map<String, dynamic>>());
      expect(storage.loadPreferences().countryId, 'Kenya');
    },
  );

  test('does not complete onboarding without a valid snapshot', () async {
    final shared = await SharedPreferences.getInstance();
    final storage = OnboardingStorage(shared);

    await expectLater(storage.markOnboardingComplete(), throwsStateError);
    expect(storage.isOnboardingComplete(), isFalse);
  });

  test(
    'migrates a complete legacy guest preference without inventing data',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'pref_country_code': 'KE',
        'pref_currency_code': 'KES',
        'pref_language_code': 'en',
      });
      final shared = await SharedPreferences.getInstance();
      final storage = OnboardingStorage(shared);

      final restored = storage.loadPreferences();
      expect(restored.hasValidPreference, isTrue);
      expect(restored.countryId, 'KE');
      expect(restored.currencyId, 'KES');
      expect(restored.languageId, 'en');
    },
  );
}
