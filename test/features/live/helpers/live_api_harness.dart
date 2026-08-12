import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_api.dart';
import 'package:africaonlinestores/features/live/data/live_api.dart';
import 'package:africaonlinestores/features/live/data/live_cohost_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/test_preferences.dart';
import '../../../test_config/test_environment.dart';

class LiveApiHarness {
  const LiveApiHarness({
    required this.client,
    required this.liveApi,
    required this.commentsApi,
    required this.cohostApi,
    required this.adapter,
  });

  final ApiClient client;
  final LiveApi liveApi;
  final LiveCommentsApi commentsApi;
  final LiveCohostApi cohostApi;
  final RecordingHttpClientAdapter adapter;
}

Future<LiveApiHarness> buildLiveApiHarness(
  RecordingHttpClientAdapter adapter,
) async {
  final preferences = await setUpTestPreferences();
  final onboardingStorage = OnboardingStorage(preferences);

  final clientProvider = Provider<ApiClient>((Ref ref) {
    final client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
    client.dio.httpClientAdapter = adapter;
    ref.onDispose(client.dispose);
    return client;
  });

  final container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
    ],
  );
  final client = container.read(clientProvider);

  return LiveApiHarness(
    client: client,
    liveApi: LiveApi(client),
    commentsApi: LiveCommentsApi(client),
    cohostApi: LiveCohostApi(client),
    adapter: adapter,
  );
}
