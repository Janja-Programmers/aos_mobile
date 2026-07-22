import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/test_preferences.dart';
import '../../../test_config/test_environment.dart';

class AuthApiHarness {
  const AuthApiHarness({
    required this.client,
    required this.api,
    required this.adapter,
  });

  final ApiClient client;
  final AuthApi api;
  final RecordingHttpClientAdapter adapter;
}

Future<AuthApiHarness> buildAuthApiHarness(
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

  final container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
    ],
  );
  final ApiClient resolvedClient = container.read(clientProvider);

  return AuthApiHarness(
    client: resolvedClient,
    api: AuthApi(resolvedClient),
    adapter: adapter,
  );
}
