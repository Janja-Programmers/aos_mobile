import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_ads_provider.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';
import '../../../account_profile/helpers/account_profile_api_harness.dart';

void main() {
  test('seller discovery params preserve canonical seller scope', () {
    final params = sellerAdsParams(' SELLER-PUBLIC-001 ');

    expect(params.sellerId, 'SELLER-PUBLIC-001');
    expect(params.parentCategoryId, isNull);
    expect(params.initialCategoryId, isNull);
  });

  test(
    'seller provider wires sort and filters through existing Ads controller',
    () async {
      final adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{
              'items': <Object?>[],
              'pagination': <String, dynamic>{
                'limit': 20,
                'offset': 0,
                'returned': 0,
                'next_cursor': null,
              },
            },
          },
        }),
      );
      final harness = await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);

      final container = ProviderContainer(
        overrides: [adsApiProvider.overrideWithValue(AdsApi(harness.client))],
      );
      addTearDown(container.dispose);

      const sellerId = 'SELLER-PUBLIC-001';
      final subscription = container.listen(
        sellerAdsProvider(sellerId),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForRequestCount(adapter, 1);
      expect(adapter.requests[0].queryParameters['seller'], sellerId);

      final controller = container.read(sellerAdsProvider(sellerId).notifier);
      controller.setSortType(AdsSort.priceHigh);
      await _waitForRequestCount(adapter, 2);
      expect(adapter.requests[1].queryParameters['seller'], sellerId);
      expect(adapter.requests[1].queryParameters['sort'], 'price_high');

      controller.applyFilters(priceMin: 500, priceMax: 5000, ratingMin: 4);
      await _waitForRequestCount(adapter, 3);
      final filtered = adapter.requests[2].queryParameters;
      expect(filtered['seller'], sellerId);
      expect(filtered['sort'], 'price_high');
      expect(filtered['price_min'], 500);
      expect(filtered['price_max'], 5000);
      expect(filtered['rating_min'], 4);
    },
  );

  test(
    'seller provider paginates public Ads responses without has_more',
    () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        final offset = options.queryParameters['offset'] as int? ?? 0;
        final items = offset == 0
            ? List<Object?>.generate(
                20,
                (index) => <String, dynamic>{
                  'id': 'AD-${index + 1}',
                  'title': 'Ad ${index + 1}',
                },
              )
            : <Object?>[
                <String, dynamic>{'id': 'AD-21', 'title': 'Ad 21'},
              ];

        return jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{
              'items': items,
              'pagination': <String, dynamic>{
                'limit': 20,
                'offset': offset,
                'returned': items.length,
                'next_cursor': null,
              },
            },
          },
        });
      });
      final harness = await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);

      final container = ProviderContainer(
        overrides: [adsApiProvider.overrideWithValue(AdsApi(harness.client))],
      );
      addTearDown(container.dispose);

      const sellerId = 'SELLER-PUBLIC-001';
      final subscription = container.listen(
        sellerAdsProvider(sellerId),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitForItems(container, sellerId, 20);
      var state = container.read(sellerAdsProvider(sellerId));
      expect(state.items, hasLength(20));
      expect(state.hasMore, isTrue);

      await container.read(sellerAdsProvider(sellerId).notifier).load();
      state = container.read(sellerAdsProvider(sellerId));

      expect(state.items, hasLength(21));
      expect(state.items.last.id, 'AD-21');
      expect(state.hasMore, isFalse);
      expect(adapter.requests[1].queryParameters['offset'], 20);
    },
  );
}

Future<void> _waitForItems(
  ProviderContainer container,
  String sellerId,
  int count,
) async {
  for (var attempt = 0; attempt < 50; attempt += 1) {
    final state = container.read(sellerAdsProvider(sellerId));
    if (!state.loading && state.items.length >= count) return;
    await Future<void>.delayed(Duration.zero);
  }

  final state = container.read(sellerAdsProvider(sellerId));
  fail('Expected at least $count item(s), found ${state.items.length}.');
}

Future<void> _waitForRequestCount(
  RecordingHttpClientAdapter adapter,
  int count,
) async {
  for (var attempt = 0; attempt < 50; attempt += 1) {
    if (adapter.requests.length >= count) return;
    await Future<void>.delayed(Duration.zero);
  }

  fail(
    'Expected at least $count request(s), found ${adapter.requests.length}.',
  );
}
