import 'package:africaonlinestores/core/api/session_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fakes/fake_session_storage.dart';
import '../../../../helpers/test_preferences.dart';

void main() {
  group('session SID storage contract', () {
    test('fake secure storage saves, reads, and clears the SID', () async {
      final FakeSessionStorage storage = FakeSessionStorage();

      await storage.setSid('test-session-id');
      expect(await storage.getSid(), 'test-session-id');

      await storage.clearSid();
      expect(await storage.getSid(), isNull);
    });
  });

  group('remembered login preferences', () {
    test(
      'remember-me and identifier use SharedPreferences independently of SID',
      () async {
        final SharedPreferences preferences = await setUpTestPreferences();
        const SessionStorage storage = SessionStorage();

        await storage.setRememberMe(true);
        await storage.setRememberedEmail('user@example.invalid');

        expect(await storage.getRememberMe(), isTrue);
        expect(await storage.getRememberedEmail(), 'user@example.invalid');
        expect(
          preferences.getKeys(),
          containsAll(<String>{'aos_remember_me', 'aos_email'}),
        );
      },
    );

    test(
      'remember-me false allows the remembered identifier to be cleared',
      () async {
        await setUpTestPreferences(
          values: <String, Object>{
            'aos_remember_me': true,
            'aos_email': 'user@example.invalid',
          },
        );
        const SessionStorage storage = SessionStorage();

        await storage.setRememberMe(false);
        await storage.clearRememberedEmail();

        expect(await storage.getRememberMe(), isFalse);
        expect(await storage.getRememberedEmail(), isEmpty);
      },
    );

    test('password values are never written by the storage API', () async {
      final SharedPreferences preferences = await setUpTestPreferences();
      const SessionStorage storage = SessionStorage();

      await storage.setRememberMe(true);
      await storage.setRememberedEmail('user@example.invalid');

      expect(
        preferences.getKeys().where((String key) => key.contains('password')),
        isEmpty,
      );
      expect(
        preferences.getKeys().where((String key) => key.contains('pwd')),
        isEmpty,
      );
      expect(
        preferences.getKeys().map(preferences.get),
        isNot(contains('fake-password')),
      );
    });
  });
}
