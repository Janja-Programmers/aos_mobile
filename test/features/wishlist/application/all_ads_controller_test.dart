import 'dart:async';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_controller_provider.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_params.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/provider_container.dart';
import '../../../helpers/test_preferences.dart';
import '../../../test_config/test_environment.dart';

void main() {
  test('wishlist listing follows backend pagination metadata', () async {
    final harness = await _buildHarness(itemCount: 20, hasMore: false);
    const params = AllAdsParams(mode: AllAdsMode.wishlist);

    final subscription = harness.container.listen(
      allAdsControllerProvider(params),
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await pumpEventQueue(times: 5);

    final state = harness.container.read(allAdsControllerProvider(params));
    expect(state.items, hasLength(20));
    expect(state.hasMore, isFalse);
    expect(harness.api.listCalls, 1);
  });

  test('one-character wishlist search does not call the backend', () async {
    final harness = await _buildHarness(itemCount: 0, hasMore: false);
    const params = AllAdsParams(mode: AllAdsMode.wishlist);
    final subscription = harness.container.listen(
      allAdsControllerProvider(params),
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final controller = harness.container.read(
      allAdsControllerProvider(params).notifier,
    );
    await pumpEventQueue(times: 5);
    expect(harness.api.listCalls, 1);

    controller.setWishlistSearch('a');
    await Future<void>.delayed(const Duration(milliseconds: 450));

    expect(harness.api.listCalls, 1);
    expect(
      harness.container.read(allAdsControllerProvider(params)).wishlistQuery,
      'a',
    );

    controller.setWishlistSearch('ab');
    await Future<void>.delayed(const Duration(milliseconds: 450));
    await pumpEventQueue(times: 5);

    expect(harness.api.listCalls, 2);
    expect(harness.api.lastQuery, 'ab');
  });

  test(
    'stale wishlist responses cannot overwrite newer search results',
    () async {
      final harness = await _buildDeferredHarness();
      const params = AllAdsParams(mode: AllAdsMode.wishlist);
      final subscription = harness.container.listen(
        allAdsControllerProvider(params),
        (previous, next) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await pumpEventQueue(times: 5);

      expect(harness.api.requests, hasLength(1));

      final controller = harness.container.read(
        allAdsControllerProvider(params).notifier,
      );
      controller.setWishlistSearch('new');
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await pumpEventQueue(times: 5);

      expect(harness.api.requests, hasLength(2));
      expect(harness.api.queries, <String?>[null, 'new']);

      harness.api.complete(1, id: 'AD-NEW', title: 'New result');
      await pumpEventQueue(times: 5);

      expect(
        harness.container
            .read(allAdsControllerProvider(params))
            .items
            .single
            .id,
        'AD-NEW',
      );

      harness.api.complete(0, id: 'AD-OLD', title: 'Old result');
      await pumpEventQueue(times: 5);

      expect(
        harness.container
            .read(allAdsControllerProvider(params))
            .items
            .single
            .id,
        'AD-NEW',
      );
    },
  );
}

class _RecordingWishlistAdsApi extends AdsApi {
  _RecordingWishlistAdsApi(
    super.client, {
    required this.itemCount,
    required this.hasMore,
  });

  final int itemCount;
  final bool hasMore;
  int listCalls = 0;
  String? lastQuery;

  @override
  Future<Either<Failure, Map<String, dynamic>>> listWishlist({
    int limit = 20,
    int offset = 0,
    String? sort,
    String? q,
    int? priceMin,
    int? priceMax,
    int? ratingMin,
    bool? verifiedSeller,
  }) async {
    listCalls += 1;
    lastQuery = q;
    final items = List<Map<String, dynamic>>.generate(
      itemCount,
      (index) => <String, dynamic>{
        'id': 'AD-$index',
        'title': 'Ad $index',
        'is_wishlisted': true,
      },
      growable: false,
    );

    return Either<Failure, Map<String, dynamic>>.right(<String, dynamic>{
      'ok': true,
      'data': <String, dynamic>{
        'items': items,
        'pagination': <String, dynamic>{
          'limit': limit,
          'offset': offset,
          'returned': items.length,
          'has_more': hasMore,
          'next_offset': hasMore ? offset + items.length : null,
          'next_cursor': null,
        },
      },
    });
  }
}

class _AllAdsHarness {
  const _AllAdsHarness({required this.container, required this.api});

  final ProviderContainer container;
  final _RecordingWishlistAdsApi api;
}

Future<_AllAdsHarness> _buildHarness({
  required int itemCount,
  required bool hasMore,
}) async {
  final preferences = await setUpTestPreferences();
  final onboardingStorage = OnboardingStorage(preferences);
  late _RecordingWishlistAdsApi api;

  final clientProvider = Provider<ApiClient>((Ref ref) {
    final client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
    ref.onDispose(client.dispose);
    return client;
  });

  final container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
      adsApiProvider.overrideWith((Ref ref) {
        // ignore: join_return_with_assignment
        api = _RecordingWishlistAdsApi(
          ref.read(clientProvider),
          itemCount: itemCount,
          hasMore: hasMore,
        );
        return api;
      }),
    ],
  );

  container.read(adsApiProvider);
  return _AllAdsHarness(container: container, api: api);
}

class _DeferredWishlistAdsApi extends AdsApi {
  _DeferredWishlistAdsApi(super.client);

  final List<Completer<Either<Failure, Map<String, dynamic>>>> requests = [];
  final List<String?> queries = [];

  @override
  Future<Either<Failure, Map<String, dynamic>>> listWishlist({
    int limit = 20,
    int offset = 0,
    String? sort,
    String? q,
    int? priceMin,
    int? priceMax,
    int? ratingMin,
    bool? verifiedSeller,
  }) {
    queries.add(q);
    final completer = Completer<Either<Failure, Map<String, dynamic>>>();
    requests.add(completer);
    return completer.future;
  }

  void complete(int index, {required String id, required String title}) {
    requests[index].complete(
      Either<Failure, Map<String, dynamic>>.right(<String, dynamic>{
        'ok': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{'id': id, 'title': title, 'is_wishlisted': true},
          ],
          'pagination': <String, dynamic>{
            'limit': 20,
            'offset': 0,
            'returned': 1,
            'has_more': false,
            'next_offset': null,
            'next_cursor': null,
          },
        },
      }),
    );
  }
}

class _DeferredHarness {
  const _DeferredHarness({required this.container, required this.api});

  final ProviderContainer container;
  final _DeferredWishlistAdsApi api;
}

Future<_DeferredHarness> _buildDeferredHarness() async {
  final preferences = await setUpTestPreferences();
  final onboardingStorage = OnboardingStorage(preferences);
  late _DeferredWishlistAdsApi api;

  final clientProvider = Provider<ApiClient>((Ref ref) {
    final client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
    ref.onDispose(client.dispose);
    return client;
  });

  final container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
      adsApiProvider.overrideWith((Ref ref) {
        // ignore: join_return_with_assignment
        api = _DeferredWishlistAdsApi(ref.read(clientProvider));
        return api;
      }),
    ],
  );

  container.read(adsApiProvider);
  return _DeferredHarness(container: container, api: api);
}
