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
    'listAds forwards seller scope with canonical sort and filters',
    () async {
      final adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{
              'items': <Object?>[],
              'pagination': <String, dynamic>{
                'limit': 20,
                'offset': 20,
                'returned': 0,
                'next_cursor': null,
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
      addTearDown(container.dispose);

      final provider = Provider<ApiClient>((Ref ref) {
        final client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
        client.dio.httpClientAdapter = adapter;
        ref.onDispose(client.dispose);
        return client;
      });
      final api = AdsApi(container.read(provider));

      final result = await api.listAds(
        sellerId: ' SELLER-PUBLIC-001 ',
        sort: 'price_high',
        priceMin: 500,
        priceMax: 5000,
        ratingMin: 4,
        offset: 20,
      );

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.path, ApiEndpoints.listAdsEndpoint);
      expect(
        adapter.singleRequest.queryParameters['seller'],
        'SELLER-PUBLIC-001',
      );
      expect(adapter.singleRequest.queryParameters['sort'], 'price_high');
      expect(adapter.singleRequest.queryParameters['price_min'], 500);
      expect(adapter.singleRequest.queryParameters['price_max'], 5000);
      expect(adapter.singleRequest.queryParameters['rating_min'], 4);
      expect(adapter.singleRequest.queryParameters['limit'], 20);
      expect(adapter.singleRequest.queryParameters['offset'], 20);
    },
  );
}
