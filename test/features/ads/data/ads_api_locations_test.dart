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
    'getLocations sends search pagination and parses next page metadata',
    () async {
      final adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{
              'locations': <Object?>[
                <String, dynamic>{
                  'id': 'LOC-21',
                  'name': 'Westlands',
                  'country': 'KE',
                  'sort_order': 21,
                },
              ],
              'pagination': <String, dynamic>{
                'limit': 20,
                'offset': 20,
                'returned': 1,
                'has_more': true,
                'next_offset': 40,
              },
            },
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

      final result = await api.getLocations(query: ' west ', offset: 20);

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.path, ApiEndpoints.getLocationsEndpoint);
      expect(adapter.singleRequest.queryParameters['q'], 'west');
      expect(adapter.singleRequest.queryParameters['limit'], 20);
      expect(adapter.singleRequest.queryParameters['offset'], 20);
      final page = result.rightOrNull!;
      expect(page.items.single.id, 'LOC-21');
      expect(page.items.single.name, 'Westlands');
      expect(page.hasMore, isTrue);
      expect(page.nextOffset, 40);
    },
  );
}
