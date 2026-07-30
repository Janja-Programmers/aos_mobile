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
  group('AdsApi wishlist contract', () {
    test('listWishlist sends only backend-supported query fields', () async {
      final adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'message': 'Wishlist fetched.',
            'data': <String, dynamic>{
              'items': <Object?>[],
              'pagination': <String, dynamic>{
                'limit': 20,
                'offset': 40,
                'returned': 0,
                'has_more': false,
                'next_offset': null,
                'next_cursor': null,
              },
            },
          },
        }),
      );
      final harness = await _buildHarness(adapter);

      final result = await harness.api.listWishlist(
        offset: 40,
        sort: 'recent',
        q: ' bicycle ',
        priceMin: 100,
        priceMax: 5000,
        ratingMin: 4,
        verifiedSeller: true,
      );

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, ApiEndpoints.listWishlistEndpoint);
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'limit': 20,
        'offset': 40,
        'sort': 'recent',
        'q': 'bicycle',
        'price_min': 100,
        'price_max': 5000,
        'rating_min': 4,
        'verified_seller': 1,
      });
      expect(
        adapter.singleRequest.queryParameters.containsKey('search'),
        isFalse,
      );
      expect(
        adapter.singleRequest.queryParameters.containsKey('verified_sellers'),
        isFalse,
      );
      expect(
        adapter.singleRequest.queryParameters.containsKey('preferred_store'),
        isFalse,
      );
    });

    test('rejects an oversized page before making a request', () async {
      final adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => throw StateError('Unexpected request'),
      );
      final harness = await _buildHarness(adapter);

      final result = await harness.api.listWishlist(limit: 51);

      expect(result.isLeft, isTrue);
      expect(adapter.requests, isEmpty);
    });

    test('rejects a one-character query before making a request', () async {
      final adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => throw StateError('Unexpected request'),
      );
      final harness = await _buildHarness(adapter);

      final result = await harness.api.listWishlist(q: 'a');

      expect(result.isLeft, isTrue);
      expect(adapter.requests, isEmpty);
    });

    test('toggleWishlist sends the explicit desired state', () async {
      final adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'message': 'Wishlist updated.',
            'data': <String, dynamic>{
              'ad_id': 'AD-001',
              'wishlisted': true,
              'changed': true,
              'wishlist_count': 1,
            },
          },
        }),
      );
      final harness = await _buildHarness(adapter);

      final result = await harness.api.toggleWishlist(
        adId: ' AD-001 ',
        wishlisted: true,
      );

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.method, 'POST');
      expect(adapter.singleRequest.path, ApiEndpoints.toggleWishlistEndpoint);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'ad_id': 'AD-001',
        'wishlisted': 1,
      });
    });
  });
}

class _AdsApiHarness {
  const _AdsApiHarness({required this.api});

  final AdsApi api;
}

Future<_AdsApiHarness> _buildHarness(
  RecordingHttpClientAdapter adapter,
) async {
  final preferences = await setUpTestPreferences();
  final onboardingStorage = OnboardingStorage(preferences);
  final clientProvider = Provider<ApiClient>((Ref ref) {
    final client = ApiClient(
      baseUrl: TestEnvironment.apiBaseUrl,
      ref: ref,
    );
    client.dio.httpClientAdapter = adapter;
    ref.onDispose(client.dispose);
    return client;
  });

  final container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
    ],
  );
  final resolvedClient = container.read(clientProvider);

  return _AdsApiHarness(api: AdsApi(resolvedClient));
}
