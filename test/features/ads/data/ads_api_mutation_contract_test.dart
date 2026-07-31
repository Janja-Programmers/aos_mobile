import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/test_preferences.dart';
import '../../../test_config/test_environment.dart';

void main() {
  test(
    'create and draft mutations preserve the canonical payload envelope',
    () async {
      final adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{'id': 'TEST-1'},
          },
        }),
      );
      final preferences = await setUpTestPreferences();
      final container = createTestContainer(
        overrides: <Override>[
          onboardingStorageProvider.overrideWithValue(
            OnboardingStorage(preferences),
          ),
        ],
      );
      final provider = Provider<ApiClient>((Ref ref) {
        final client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
        client.dio.httpClientAdapter = adapter;
        ref.onDispose(client.dispose);
        return client;
      });
      final api = AdsApi(container.read(provider));
      final payload = <String, dynamic>{
        'title': 'Valid ad title',
        'location': 'LOC-1',
        'category': 'CAT-1',
        'description':
            'A valid advertisement description for contract testing.',
        'details': <Object?>[],
        'images': <Object?>[],
      };

      await api.createAd(payload: payload);
      await api.saveAdDraft(payload: payload);
      await api.upsertAdDraft(draftId: 'DRAFT-1', payload: payload);

      expect(adapter.requests[0].path, ApiEndpoints.createAdEndpoint);
      expect(adapter.requests[0].data, payload);
      expect(adapter.requests[1].path, ApiEndpoints.upsertAdDraftEndpoint);
      expect(adapter.requests[1].data, <String, dynamic>{'payload': payload});
      expect(adapter.requests[2].path, ApiEndpoints.upsertAdDraftEndpoint);
      expect(adapter.requests[2].data, <String, dynamic>{
        'draft_id': 'DRAFT-1',
        'payload': payload,
      });
    },
  );
}
