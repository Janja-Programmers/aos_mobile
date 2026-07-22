import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_controller_harness.dart';

void main() {
  test(
    'regression: top-level SID cannot authenticate without data.session.sid',
    () async {
      final harness = await buildAuthControllerHarness(
        loginHandler: (String identifier, String password) async {
          return successfulAuthResponse(<String, dynamic>{
            'ok': true,
            'sid': 'legacy-top-level-sid',
            'data': <String, dynamic>{
              'user': <String, dynamic>{
                'email': 'user@example.invalid',
                'full_name': 'Test User',
              },
            },
          });
        },
      );

      final result = await harness.controller.login(
        identifier: 'user@example.invalid',
        password: 'fake-password',
        rememberMe: true,
      );

      expect(result.isLeft, isTrue);
      expect(harness.state, isA<AuthGuest>());
      expect(await harness.storage.getSid(), isNull);
    },
  );

  test(
    'regression: legacy code-only payload does not masquerade as current error',
    () {
      final Failure failure = Failure.fromServerPayload(<String, dynamic>{
        'code': 'INVALID_CREDENTIALS',
        'message': 'Legacy error contract.',
      });

      expect(failure.error, isNull);
      expect(failure.message, 'Legacy error contract.');
    },
  );

  test(
    'regression: stale SID alone cannot survive malformed current-user data',
    () async {
      final harness = await buildAuthControllerHarness(
        storedSid: 'stale-test-session-id',
        meHandler: () async => successfulAuthResponse(<String, dynamic>{
          'ok': true,
          'data': <String, dynamic>{
            'preferences': <String, dynamic>{},
            'roles': <String>[],
          },
        }),
      );

      expect(harness.state, isA<AuthGuest>());
      expect(await harness.storage.getSid(), isNull);
    },
  );

  test(
    'regression: explicit logout removes authenticated state from provider cache',
    () async {
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async => successfulAuthResponse(<String, dynamic>{
          'ok': true,
          'data': <String, dynamic>{
            'user': <String, dynamic>{
              'email': 'user@example.invalid',
              'full_name': 'Test User',
            },
            'preferences': <String, dynamic>{},
            'roles': <String>['AOS User'],
            'seller': <String, dynamic>{'is_seller': false},
          },
        }),
      );

      expect(harness.state, isA<AuthAuthenticated>());

      await harness.controller.logout();

      expect(harness.state, isA<AuthGuest>());
      expect(await harness.storage.getSid(), isNull);
    },
  );
}
