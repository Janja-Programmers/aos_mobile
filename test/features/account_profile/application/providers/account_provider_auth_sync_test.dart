import 'dart:async';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/account/domain/account_state.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/auth/data/auth_api_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_session_storage.dart';
import '../../../../helpers/provider_container.dart';
import '../../../../helpers/test_preferences.dart';
import '../../../../test_config/test_environment.dart';
import '../../fakes/mutable_auth_controller.dart';
import '../../fakes/scripted_accounts_api.dart';
import '../../helpers/account_profile_fixture.dart';

void main() {
  test('logout recreates Account state without stale profile data', () async {
    final preferences = await setUpTestPreferences();
    final OnboardingStorage onboardingStorage = OnboardingStorage(preferences);
    final FakeSessionStorage storage = FakeSessionStorage(
      sid: 'test-session-id',
    );
    final Map<String, dynamic> profilePayload =
        await loadAccountProfileMessageFixture('own_profile.json');

    late ApiClient client;
    late MutableAuthController authController;
    late ScriptedAccountsApi accountsApi;

    final ProviderContainer container = createTestContainer(
      overrides: <Override>[
        onboardingStorageProvider.overrideWithValue(onboardingStorage),
        sessionStorageProvider.overrideWithValue(storage),
        apiClientProvider.overrideWith((Ref ref) {
          client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
          ref.onDispose(client.dispose);
          return client;
        }),
        authApiProvider.overrideWith((Ref ref) {
          return AuthApi(ref.watch(apiClientProvider));
        }),
        authControllerProvider.overrideWith((Ref ref) {
          authController = MutableAuthController(
            ref: ref,
            api: ref.watch(authApiProvider),
            apiClient: ref.watch(apiClientProvider),
            storage: ref.watch(sessionStorageProvider),
            initialState: AuthAuthenticated(
              user: AuthUser(
                email: 'owner@example.invalid',
                fullName: 'Test Owner',
              ),
              sid: 'test-session-id',
            ),
          );
          return authController;
        }),
        accountsApiProvider.overrideWith((Ref ref) {
          accountsApi = ScriptedAccountsApi(
            ref.watch(apiClientProvider),
            getProfileHandler: (_) async => Either.right(profilePayload),
          );
          return accountsApi;
        }),
      ],
    );
    addTearDown(container.dispose);

    final Completer<void> loaded = Completer<void>();
    final ProviderSubscription<AccountState> subscription = container
        .listen<AccountState>(accountsControllerProvider, (
          AccountState? previous,
          AccountState next,
        ) {
          if (next.profile.isNotEmpty && !loaded.isCompleted) {
            loaded.complete();
          }
        }, fireImmediately: true);
    addTearDown(subscription.close);

    await loaded.future;
    expect(container.read(accountsControllerProvider).profile, isNotEmpty);

    authController.replace(const AuthGuest());
    await Future<void>.value();

    final AccountState afterLogout = container.read(accountsControllerProvider);
    expect(afterLogout.loading, isFalse);
    expect(afterLogout.profile, isEmpty);
    expect(accountsApi.getProfileCalls, 1);
  });
}
