import 'dart:async';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/app/bootstrap/app_bootstrap_state.dart';
import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/data/auth_api_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../fakes/fake_session_storage.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/test_preferences.dart';
import '../../../test_config/test_environment.dart';
import '../fakes/scripted_auth_api.dart';

class AuthControllerHarness {
  const AuthControllerHarness({
    required this.container,
    required this.controller,
    required this.api,
    required this.client,
    required this.storage,
  });

  final ProviderContainer container;
  final AuthController controller;
  final ScriptedAuthApi api;
  final ApiClient client;
  final FakeSessionStorage storage;

  AuthState get state => container.read(authControllerProvider);
}

Future<AuthControllerHarness> buildAuthControllerHarness({
  String? storedSid,
  LoginHandler? loginHandler,
  NoArgumentAuthHandler? meHandler,
  NoArgumentAuthHandler? logoutHandler,
  DateTime Function()? now,
  bool waitForInitialization = true,
}) async {
  final preferences = await setUpTestPreferences();
  final OnboardingStorage onboardingStorage = OnboardingStorage(preferences);
  final FakeSessionStorage storage = FakeSessionStorage(sid: storedSid);

  late ApiClient client;
  late ScriptedAuthApi api;

  final ProviderContainer container = createTestContainer(
    overrides: <Override>[
      appBootstrapProvider.overrideWithValue(
        const AppBootstrapState(isReady: true, onboardingCompleted: true),
      ),
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
      sessionStorageProvider.overrideWithValue(storage),
      apiClientProvider.overrideWith((Ref ref) {
        client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
        ref.onDispose(client.dispose);
        return client;
      }),
      authApiProvider.overrideWith((Ref ref) {
        // ignore: join_return_with_assignment
        api = ScriptedAuthApi(
          ref.watch(apiClientProvider),
          loginHandler: loginHandler,
          meHandler: meHandler,
          logoutHandler: logoutHandler,
        );
        return api;
      }),
      if (now != null)
        authControllerProvider.overrideWith((Ref ref) {
          final AuthController controller = AuthController(
            ref: ref,
            api: ref.watch(authApiProvider),
            apiClient: ref.watch(apiClientProvider),
            storage: ref.watch(sessionStorageProvider),
            now: now,
          );
          unawaited(controller.init());
          return controller;
        }),
    ],
  );

  final Completer<void> initialized = Completer<void>();
  final ProviderSubscription<AuthState> subscription = container
      .listen<AuthState>(authControllerProvider, (
        AuthState? previous,
        AuthState next,
      ) {
        final bool isTerminal =
            next is AuthGuest ||
            next is AuthAuthenticated ||
            next is AuthRestorationFailure;
        if (isTerminal && !initialized.isCompleted) {
          initialized.complete();
        }
      }, fireImmediately: true);

  final AuthController controller = container.read(
    authControllerProvider.notifier,
  );
  final AuthState currentState = container.read(authControllerProvider);
  if (waitForInitialization &&
      (currentState is AuthLoading || currentState is AuthRestoring)) {
    await initialized.future.timeout(const Duration(seconds: 2));
  }
  subscription.close();

  return AuthControllerHarness(
    container: container,
    controller: controller,
    api: api,
    client: client,
    storage: storage,
  );
}

AuthApiResponse successfulAuthResponse(Map<String, dynamic> payload) {
  return Either<Failure, Map<String, dynamic>>.right(payload);
}

AuthApiResponse failedAuthResponse(Failure failure) {
  return Either<Failure, Map<String, dynamic>>.left(failure);
}
