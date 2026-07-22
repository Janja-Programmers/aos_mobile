import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_controller_harness.dart';
import '../../helpers/auth_fixture.dart';

void main() {
  group('authentication providers', () {
    test('isAuthenticated is false for a guest session', () async {
      final harness = await buildAuthControllerHarness();

      expect(harness.container.read(isAuthenticatedProvider), isFalse);
      expect(harness.container.read(authControllerProvider), isA<AuthGuest>());
    });

    test(
      'isAuthenticated derives true only after complete login hydration',
      () async {
        final Map<String, dynamic> payload = await loadAuthMessageFixture(
          'login_success.json',
        );
        final harness = await buildAuthControllerHarness(
          loginHandler: (String identifier, String password) async {
            return successfulAuthResponse(payload);
          },
        );

        expect(harness.container.read(isAuthenticatedProvider), isFalse);

        await harness.controller.login(
          identifier: 'user@example.invalid',
          password: 'fake-password',
          rememberMe: true,
        );

        expect(harness.container.read(isAuthenticatedProvider), isTrue);
        expect(
          harness.container.read(authControllerProvider),
          isA<AuthAuthenticated>(),
        );
      },
    );

    test('logout synchronizes the derived provider back to false', () async {
      final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
        'me_success.json',
      );
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async => successfulAuthResponse(mePayload),
      );

      expect(harness.container.read(isAuthenticatedProvider), isTrue);

      await harness.controller.logout();

      expect(harness.container.read(isAuthenticatedProvider), isFalse);
      expect(harness.container.read(authControllerProvider), isA<AuthGuest>());
    });

    test(
      'profile and preference updates preserve SID and authorization state',
      () async {
        final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
          'me_success.json',
        );
        final harness = await buildAuthControllerHarness(
          storedSid: 'test-session-id',
          meHandler: () async => successfulAuthResponse(mePayload),
        );

        harness.controller.setUserFromMap(<String, dynamic>{
          'email': 'user@example.invalid',
          'full_name': 'Updated Test User',
        });
        harness.controller.setPreferencesFromMap(<String, dynamic>{
          'language': 'sw',
        });

        final AuthAuthenticated state =
            harness.container.read(authControllerProvider) as AuthAuthenticated;
        expect(state.sid, 'test-session-id');
        expect(state.user.fullName, 'Updated Test User');
        expect(state.preferences['language'], 'sw');
        expect(state.roles, <String>['AOS User']);
      },
    );
  });
}
