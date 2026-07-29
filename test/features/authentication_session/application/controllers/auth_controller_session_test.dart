import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';
import '../../fakes/scripted_auth_api.dart';
import '../../helpers/auth_controller_harness.dart';
import '../../helpers/auth_fixture.dart';

void main() {
  group('session restoration', () {
    test('no stored SID selects guest without calling /me', () async {
      final harness = await buildAuthControllerHarness();

      expect(harness.state, isA<AuthGuest>());
      expect(harness.api.meCalls, 0);
    });

    test('valid stored SID plus /me restores authenticated state', () async {
      final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
        'me_success.json',
      );
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async => successfulAuthResponse(mePayload),
      );

      expect(harness.api.meCalls, 1);
      expect(harness.state, isA<AuthAuthenticated>());
      final AuthAuthenticated authenticated =
          harness.state as AuthAuthenticated;
      expect(authenticated.sid, 'test-session-id');
      expect(authenticated.user.email, 'user@example.invalid');
      expect(authenticated.roles, <String>['AOS User']);
    });

    test(
      '/me restoration does not require or replace SID from its payload',
      () async {
        final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
          'me_success.json',
        );
        final Map<String, dynamic> data =
            mePayload['data'] as Map<String, dynamic>;
        data['sid'] = 'legacy-me-sid';
        final harness = await buildAuthControllerHarness(
          storedSid: 'stored-test-session-id',
          meHandler: () async => successfulAuthResponse(mePayload),
        );

        final AuthAuthenticated authenticated =
            harness.state as AuthAuthenticated;
        expect(authenticated.sid, 'stored-test-session-id');
        expect(authenticated.sid, isNot('legacy-me-sid'));
      },
    );

    test('invalid stored session clears SID and selects guest', () async {
      final harness = await buildAuthControllerHarness(
        storedSid: 'stale-test-session-id',
        meHandler: () async => failedAuthResponse(
          const Failure(
            'Please log in.',
            statusCode: 401,
            type: FailureType.unauthorized,
            error: 'SESSION_INVALID',
          ),
        ),
      );

      expect(harness.state, isA<AuthGuest>());
      expect(await harness.storage.getSid(), isNull);
    });

    test('malformed /me user becomes retryable without clearing SID', () async {
      final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
        'me_malformed_user.json',
      );
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async => successfulAuthResponse(mePayload),
      );

      expect(harness.state, isA<AuthRestorationFailure>());
      final AuthRestorationFailure failure =
          harness.state as AuthRestorationFailure;
      expect(failure.reason, AuthRestorationFailureReason.unknown);
      expect(await harness.storage.getSid(), 'test-session-id');
    });

    test(
      'temporary /me network failure is retryable and preserves stored SID',
      () async {
        final harness = await buildAuthControllerHarness(
          storedSid: 'test-session-id',
          meHandler: () async => failedAuthResponse(
            const Failure('Network unavailable.', type: FailureType.network),
          ),
        );

        expect(harness.state, isA<AuthRestorationFailure>());
        final AuthRestorationFailure failure =
            harness.state as AuthRestorationFailure;
        expect(failure.reason, AuthRestorationFailureReason.network);
        expect(await harness.storage.getSid(), 'test-session-id');
      },
    );

    test('server failure is retryable and preserves stored SID', () async {
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async => failedAuthResponse(
          const Failure(
            'Temporarily unavailable.',
            statusCode: 503,
            type: FailureType.server,
          ),
        ),
      );

      final AuthRestorationFailure failure =
          harness.state as AuthRestorationFailure;
      expect(failure.reason, AuthRestorationFailureReason.server);
      expect(await harness.storage.getSid(), 'test-session-id');
    });

    test(
      '401 without a stable invalid-session error remains retryable',
      () async {
        final harness = await buildAuthControllerHarness(
          storedSid: 'test-session-id',
          meHandler: () async => failedAuthResponse(
            const Failure(
              'Unauthorized response without a stable error identifier.',
              statusCode: 401,
              type: FailureType.unauthorized,
            ),
          ),
        );

        expect(harness.state, isA<AuthRestorationFailure>());
        expect(await harness.storage.getSid(), 'test-session-id');
      },
    );

    test('retry restores the preserved session exactly once', () async {
      final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
        'me_success.json',
      );
      int attempt = 0;
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async {
          attempt++;
          if (attempt == 1) {
            return failedAuthResponse(
              const Failure('Network unavailable.', type: FailureType.network),
            );
          }
          return successfulAuthResponse(mePayload);
        },
      );

      await harness.controller.retrySessionRestoration();

      expect(harness.api.meCalls, 2);
      expect(harness.state, isA<AuthAuthenticated>());
      expect(await harness.storage.getSid(), 'test-session-id');
    });

    test('duplicate init calls share one restoration request', () async {
      final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
        'me_success.json',
      );
      final Completer<AuthApiResponse> response =
          Completer<AuthApiResponse>();
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () => response.future,
        waitForInitialization: false,
      );

      final Future<void> first = harness.controller.init();
      final Future<void> second = harness.controller.init();
      expect(identical(first, second), isTrue);

      response.complete(successfulAuthResponse(mePayload));
      await Future.wait<void>(<Future<void>>[first, second]);

      expect(harness.api.meCalls, 1);
      expect(harness.state, isA<AuthAuthenticated>());
    });

    test('a resolved session ignores later redundant init calls', () async {
      final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
        'me_success.json',
      );
      final AuthControllerHarness harness = await buildAuthControllerHarness(
        storedSid: 'sid-existing',
        meHandler: () async => successfulAuthResponse(mePayload),
      );
      addTearDown(harness.container.dispose);

      await harness.controller.init();
      await harness.controller.init();

      expect(harness.api.meCalls, 1);
      expect(harness.controller.state, isA<AuthAuthenticated>());
    });

    test('new-account login invalidates an older restoration result', () async {
      final Map<String, dynamic> oldMePayload = await loadAuthMessageFixture(
        'me_success.json',
      );
      final Map<String, dynamic> loginPayload = await loadAuthMessageFixture(
        'login_success.json',
      );
      final Map<String, dynamic> loginData =
          loginPayload['data'] as Map<String, dynamic>;
      final Map<String, dynamic> loginUser =
          loginData['user'] as Map<String, dynamic>;
      loginUser['email'] = 'new-account@example.invalid';
      loginUser['full_name'] = 'New Account';

      final Completer<AuthApiResponse> oldResponse =
          Completer<AuthApiResponse>();
      final harness = await buildAuthControllerHarness(
        storedSid: 'old-session-id',
        meHandler: () => oldResponse.future,
        loginHandler: (String identifier, String password) async {
          return successfulAuthResponse(loginPayload);
        },
        waitForInitialization: false,
      );
      final Future<void> restoration = harness.controller.init();

      await harness.controller.login(
        identifier: 'new-account@example.invalid',
        password: 'fake-password',
        rememberMe: true,
      );
      oldResponse.complete(successfulAuthResponse(oldMePayload));
      await restoration;

      final AuthAuthenticated authenticated =
          harness.state as AuthAuthenticated;
      expect(authenticated.user.email, 'new-account@example.invalid');
      expect(await harness.storage.getSid(), authenticated.sid);
    });

    test('logout invalidates an in-flight restoration result', () async {
      final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
        'me_success.json',
      );
      final Completer<AuthApiResponse> response =
          Completer<AuthApiResponse>();
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () => response.future,
        waitForInitialization: false,
      );
      final Future<void> restoration = harness.controller.init();

      await harness.controller.logout();
      response.complete(successfulAuthResponse(mePayload));
      await restoration;

      expect(harness.state, isA<AuthGuest>());
      expect(await harness.storage.getSid(), isNull);
    });
  });

  group('logout', () {
    test('active logout clears local auth state and SID', () async {
      final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
        'me_success.json',
      );
      final Map<String, dynamic> logoutPayload = await loadAuthMessageFixture(
        'logout_success.json',
      );
      final harness = await buildAuthControllerHarness(
        storedSid: 'test-session-id',
        meHandler: () async => successfulAuthResponse(mePayload),
        logoutHandler: () async => successfulAuthResponse(logoutPayload),
      );

      expect(
        await harness.client.cookieJar.loadForRequest(harness.client.baseUri),
        isNotEmpty,
      );

      await harness.controller.logout();

      expect(harness.api.logoutCalls, 1);
      expect(harness.state, isA<AuthGuest>());
      expect(await harness.storage.getSid(), isNull);
      expect(
        await harness.client.cookieJar.loadForRequest(harness.client.baseUri),
        isEmpty,
      );
    });

    test(
      'already-expired server response cannot block local cleanup',
      () async {
        final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
          'me_success.json',
        );
        final Map<String, dynamic> expiredPayload =
            await loadAuthMessageFixture('logout_already_expired.json');
        final harness = await buildAuthControllerHarness(
          storedSid: 'test-session-id',
          meHandler: () async => successfulAuthResponse(mePayload),
          logoutHandler: () async => successfulAuthResponse(expiredPayload),
        );

        await harness.controller.logout();

        expect(harness.state, isA<AuthGuest>());
        expect(await harness.storage.getSid(), isNull);
      },
    );

    test(
      'logout transport failure still clears local session by product policy',
      () async {
        final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
          'me_success.json',
        );
        final harness = await buildAuthControllerHarness(
          storedSid: 'test-session-id',
          meHandler: () async => successfulAuthResponse(mePayload),
          logoutHandler: () async => failedAuthResponse(
            const Failure('Network unavailable.', type: FailureType.network),
          ),
        );

        await harness.controller.logout();

        expect(harness.state, isA<AuthGuest>());
        expect(await harness.storage.getSid(), isNull);
      },
    );

    test(
      'repeated logout remains safe and leaves guest state stable',
      () async {
        final harness = await buildAuthControllerHarness();

        await harness.controller.logout();
        await harness.controller.logout();

        expect(harness.api.logoutCalls, 2);
        expect(harness.state, isA<AuthGuest>());
        expect(await harness.storage.getSid(), isNull);
      },
    );
  });

  group('session expiry stream', () {
    test(
      'simultaneous 401 responses trigger one refresh and one destructive clear',
      () async {
        final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
          'me_success.json',
        );
        final harness = await buildAuthControllerHarness(
          storedSid: 'test-session-id',
          meHandler: () async => successfulAuthResponse(mePayload),
          now: () => DateTime.utc(2026, 7, 22, 12),
        );
        harness.api.meHandler = () async => failedAuthResponse(
          const Failure(
            'Session expired.',
            statusCode: 401,
            type: FailureType.unauthorized,
            error: 'SESSION_INVALID',
          ),
        );
        harness.client.dio.httpClientAdapter = RecordingHttpClientAdapter(
          (RequestOptions options) => jsonResponse(<String, dynamic>{
            'error': 'SESSION_INVALID',
          }, statusCode: 401),
        );

        final Completer<void> becameGuest = Completer<void>();
        final ProviderSubscription<AuthState> subscription = harness.container
            .listen<AuthState>(authControllerProvider, (
              AuthState? previous,
              AuthState next,
            ) {
              if (next is AuthGuest && !becameGuest.isCompleted) {
                becameGuest.complete();
              }
            });

        await Future.wait<void>(<Future<void>>[
          _expectUnauthorized(harness.client.dio, '/protected/one'),
          _expectUnauthorized(harness.client.dio, '/protected/two'),
        ]);
        await becameGuest.future.timeout(const Duration(seconds: 2));
        subscription.close();

        expect(harness.api.meCalls, 2);
        expect(harness.state, isA<AuthGuest>());
        expect(await harness.storage.getSid(), isNull);
      },
    );

    test(
      'transient refresh failure preserves an authenticated session',
      () async {
        final Map<String, dynamic> mePayload = await loadAuthMessageFixture(
          'me_success.json',
        );
        final Completer<void> refreshAttempted = Completer<void>();
        final harness = await buildAuthControllerHarness(
          storedSid: 'test-session-id',
          meHandler: () async => successfulAuthResponse(mePayload),
        );
        harness.api.meHandler = () async {
          refreshAttempted.complete();
          return failedAuthResponse(
            const Failure('Network unavailable.', type: FailureType.network),
          );
        };
        harness.client.dio.httpClientAdapter = RecordingHttpClientAdapter(
          (RequestOptions options) => jsonResponse(<String, dynamic>{
            'error': 'SESSION_INVALID',
          }, statusCode: 401),
        );

        await _expectUnauthorized(harness.client.dio, '/protected');
        await refreshAttempted.future;
        await Future<void>.delayed(Duration.zero);

        expect(harness.state, isA<AuthAuthenticated>());
        expect(await harness.storage.getSid(), 'test-session-id');
      },
    );
  });
}

Future<void> _expectUnauthorized(Dio dio, String path) async {
  try {
    await dio.get<void>(path);
    fail('Expected DioException for HTTP 401.');
  } on DioException catch (error) {
    expect(error.response?.statusCode, 401);
  }
}
