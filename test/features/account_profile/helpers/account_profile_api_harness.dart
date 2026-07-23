import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/features/account/data/account_lifecycle_api.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/social/data/social_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/test_preferences.dart';
import '../../../test_config/test_environment.dart';

class AccountProfileApiHarness {
  const AccountProfileApiHarness({
    required this.container,
    required this.client,
    required this.accountsApi,
    required this.lifecycleApi,
    required this.socialApi,
    required this.adapter,
  });

  final ProviderContainer container;
  final ApiClient client;
  final AccountsApi accountsApi;
  final AccountLifecycleApi lifecycleApi;
  final SocialApi socialApi;
  final RecordingHttpClientAdapter adapter;
}

Future<AccountProfileApiHarness> buildAccountProfileApiHarness(
  RecordingHttpClientAdapter adapter,
) async {
  final preferences = await setUpTestPreferences();
  final OnboardingStorage onboardingStorage = OnboardingStorage(preferences);
  late ApiClient client;

  final Provider<ApiClient> clientProvider = Provider<ApiClient>((Ref ref) {
    client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
    client.dio.httpClientAdapter = adapter;
    ref.onDispose(client.dispose);
    return client;
  });

  final ProviderContainer container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
    ],
  );
  final ApiClient resolvedClient = container.read(clientProvider);

  return AccountProfileApiHarness(
    container: container,
    client: resolvedClient,
    accountsApi: AccountsApi(resolvedClient),
    lifecycleApi: AccountLifecycleApi(resolvedClient),
    socialApi: SocialApi(resolvedClient),
    adapter: adapter,
  );
}
