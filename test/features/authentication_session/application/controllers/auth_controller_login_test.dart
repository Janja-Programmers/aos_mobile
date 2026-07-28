import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/scripted_auth_api.dart';
import '../../helpers/auth_controller_harness.dart';
import '../../helpers/auth_fixture.dart';

void main() {
  group('AuthController login', () {
    test('stores nested SID and emits complete authenticated state', () async {
      final Map<String, dynamic> payload = await loadAuthMessageFixture(
        'login_success.json',
      );
      final harness = await buildAuthControllerHarness(
        loginHandler: (String identifier, String password) async {
          return successfulAuthResponse(payload);
        },
      );

      final result = await harness.controller.login(
        identifier: '  USER@EXAMPLE.INVALID  ',
        password: 'fake-password',
        rememberMe: true,
      );

      expect(result.isRight, isTrue);
      expect(harness.api.loginCalls, 1);
      expect(harness.api.lastIdentifier, 'user@example.invalid');
      expect(harness.api.lastPassword, 'fake-password');
      expect(await harness.storage.getSid(), 'test-session-id');
      expect(await harness.storage.getRememberMe(), isTrue);
      expect(
        await harness.storage.getRememberedEmail(),
        'user@example.invalid',
      );

      final AuthAuthenticated authenticated =
          harness.state as AuthAuthenticated;
      expect(authenticated.user.email, 'user@example.invalid');
      expect(authenticated.roles, <String>['AOS User']);
      expect(
        authenticated.preferences['currency'],
        containsPair('code', 'KES'),
      );
      expect(authenticated.seller.isSeller, isTrue);
      expect(authenticated.seller.sellerId, 'SELLER-TEST-1');
    });

    test(
      'remember-me false clears the remembered identifier after success',
      () async {
        final Map<String, dynamic> payload = await loadAuthMessageFixture(
          'login_success_without_seller.json',
        );
        final harness = await buildAuthControllerHarness(
          loginHandler: (String identifier, String password) async {
            return successfulAuthResponse(payload);
          },
        );
        await harness.storage.setRememberedEmail('previous@example.invalid');

        final result = await harness.controller.login(
          identifier: 'user@example.invalid',
          password: 'fake-password',
          rememberMe: false,
        );

        expect(result.isRight, isTrue);
        expect(await harness.storage.getRememberMe(), isFalse);
        expect(await harness.storage.getRememberedEmail(), isEmpty);
      },
    );

    test(
      'INVALID_CREDENTIALS leaves no authenticated or stored session',
      () async {
        final harness = await buildAuthControllerHarness(
          loginHandler: (String identifier, String password) async {
            return failedAuthResponse(
              Failure.fromServerPayload(<String, dynamic>{
                'error': 'INVALID_CREDENTIALS',
                'message': 'Unknown account.',
              }),
            );
          },
        );

        final result = await harness.controller.login(
          identifier: 'user@example.invalid',
          password: 'fake-password',
          rememberMe: true,
        );

        expect(result.isLeft, isTrue);
        expect(
          result.leftOrNull?.message,
          'Invalid email, phone, or password.',
        );
        expect(harness.state, isA<AuthGuest>());
        expect(await harness.storage.getSid(), isNull);
        expect(await harness.storage.getRememberedEmail(), isEmpty);
      },
    );

    test(
      'malformed success cannot create a partial authenticated state',
      () async {
        final Map<String, dynamic> payload = await loadAuthMessageFixture(
          'login_malformed_session.json',
        );
        final harness = await buildAuthControllerHarness(
          loginHandler: (String identifier, String password) async {
            return successfulAuthResponse(payload);
          },
        );

        final result = await harness.controller.login(
          identifier: 'user@example.invalid',
          password: 'fake-password',
          rememberMe: true,
        );

        expect(result.isLeft, isTrue);
        expect(
          result.leftOrNull?.message,
          'Login failed. No session was returned.',
        );
        expect(harness.state, isA<AuthGuest>());
        expect(await harness.storage.getSid(), isNull);
      },
    );

    test(
      'explicit authenticated false rejects a stale SID and user payload',
      () async {
        final Map<String, dynamic> payload = await loadAuthMessageFixture(
          'login_unauthenticated_session.json',
        );
        final harness = await buildAuthControllerHarness(
          loginHandler: (String identifier, String password) async {
            return successfulAuthResponse(payload);
          },
        );

        final result = await harness.controller.login(
          identifier: 'user@example.invalid',
          password: 'fake-password',
          rememberMe: true,
        );

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull?.message, contains('not authenticated'));
        expect(harness.state, isA<AuthGuest>());
        expect(await harness.storage.getSid(), isNull);
      },
    );

    test('network failure ends loading path and remains retryable', () async {
      final harness = await buildAuthControllerHarness(
        loginHandler: (String identifier, String password) async {
          return failedAuthResponse(
            const Failure('Network error.', type: FailureType.network),
          );
        },
      );

      final first = await harness.controller.login(
        identifier: 'user@example.invalid',
        password: 'fake-password',
        rememberMe: true,
      );
      final second = await harness.controller.login(
        identifier: 'user@example.invalid',
        password: 'fake-password',
        rememberMe: true,
      );

      expect(first.leftOrNull?.type, FailureType.network);
      expect(second.leftOrNull?.type, FailureType.network);
      expect(harness.api.loginCalls, 2);
      expect(harness.state, isA<AuthGuest>());
    });

    test('rapid duplicate submissions share one in-flight request', () async {
      final Map<String, dynamic> payload = await loadAuthMessageFixture(
        'login_success.json',
      );
      final Completer<AuthApiResponse> pending = Completer<AuthApiResponse>();
      final Completer<void> requestStarted = Completer<void>();
      final harness = await buildAuthControllerHarness(
        loginHandler: (String identifier, String password) {
          if (!requestStarted.isCompleted) {
            requestStarted.complete();
          }
          return pending.future;
        },
      );

      final first = harness.controller.login(
        identifier: 'user@example.invalid',
        password: 'fake-password',
        rememberMe: true,
      );
      final second = harness.controller.login(
        identifier: 'user@example.invalid',
        password: 'fake-password',
        rememberMe: true,
      );

      await requestStarted.future;
      expect(harness.api.loginCalls, 1);

      pending.complete(successfulAuthResponse(payload));
      await Future.wait(<Future<Object?>>[first, second]);

      expect(harness.api.loginCalls, 1);
      expect(harness.state, isA<AuthAuthenticated>());
    });
  });
}
