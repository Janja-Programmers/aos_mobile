import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/home/domain/market_place.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_state.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_sections.dart';
import 'package:africaonlinestores/features/home/shared/providers/marketplace_provider.dart';

class HomePageController extends AsyncNotifier<HomePageState> {
  static const _discoverLimit = 20;

  int _offset = 0;
  bool _initializing = false;
  String? _lastMarketKey;

  @override
  Future<HomePageState> build() async {
    final market = await ref.read(marketContextProvider.future);

    final marketKey = "${market.country}-${market.locationId}";

    if (_lastMarketKey == marketKey && state.value != null) {
      return state.value!;
    }

    _lastMarketKey = marketKey;
    _offset = 0;

    return _loadInitial(market);
  }

  Future<HomePageState> _loadInitial(MarketContext market) async {
    if (_initializing) {
      return state.value ?? HomePageState.initial(homeAdsSections);
    }

    _initializing = true;

    try {
      final initialState = HomePageState.initial(homeAdsSections);
      final Map<String, List> sectionResults = {};

      final futures = homeAdsSections.map((section) async {
        final String? categoryId = section.preferredCategoryNames.isNotEmpty
            ? section.preferredCategoryNames.first
            : null;

        final res = await ref
            .read(adsApiProvider)
            .listAds(
              country: market.country,
              locationId: market.locationId,
              categoryId: categoryId,
              sort: section.sort,
              promotionType: section.promotionType,
              limit: section.limit,
              offset: 0,
            );

        final items = res.fold<List>((_) => [], (payload) {
          final raw = payload['data']?['items'];
          if (raw is! List) return [];
          return raw;
        });

        sectionResults[section.key] = items;
      });

      await Future.wait(futures);

      // Discover section
      final discoverRes = await ref
          .read(adsApiProvider)
          .listAds(
            country: market.country,
            locationId: market.locationId,
            limit: _discoverLimit,
            offset: 0,
          );

      final discoverItems = discoverRes.fold<List>(
        (_) => [],
        (payload) => payload['data']?['items'] ?? [],
      );

      return initialState.copyWith(
        sectionItems: sectionResults.map(
          (k, v) =>
              MapEntry(k, v.map((e) => AOSAdListItem.fromJson(e)).toList()),
        ),
        discoverItems: discoverItems
            .map((e) => AOSAdListItem.fromJson(e))
            .toList(),
        initialLoading: false,
        hasMore: discoverItems.length == _discoverLimit,
      );
    } finally {
      _initializing = false;
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));

    _offset += _discoverLimit;

    final market = await ref.read(marketContextProvider.future);

    final res = await ref
        .read(adsApiProvider)
        .listAds(
          country: market.country,
          locationId: market.locationId,
          limit: _discoverLimit,
          offset: _offset,
        );

    final newItems = res.fold<List>(
      (_) => [],
      (payload) => payload['data']?['items'] ?? [],
    );

    final parsed = newItems.map((e) => AOSAdListItem.fromJson(e)).toList();

    state = AsyncData(
      current.copyWith(
        discoverItems: [...current.discoverItems, ...parsed],
        loadingMore: false,
        hasMore: parsed.length == _discoverLimit,
      ),
    );
  }

  Future<void> reloadForMarket(MarketContext market) async {
    _offset = 0;
    state = const AsyncLoading();
    state = AsyncData(await _loadInitial(market));
  }
}
