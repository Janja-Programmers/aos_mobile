import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/domain/market_place.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_state.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_sections.dart';
import 'package:africaonlinestores/features/home/shared/utils/category_lookup.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';

class HomePageController extends AsyncNotifier<HomePageState> {
  static const _discoverLimit = 20;
  int _offset = 0;

  @override
  Future<HomePageState> build() async {
    final market = await ref.watch(marketContextProvider.future);
    return _loadInitial(market);
  }

  Future<HomePageState> _loadInitial(MarketContext market) async {
    final initialState = HomePageState.initial(homeAdsSections);
    state = AsyncData(initialState);

    final Map<String, List> sectionResults = {};

    final futures = homeAdsSections.map((section) async {
      String? categoryId;

      if (section.preferredCategoryNames.isNotEmpty) {
        final catsState = ref.read(categoriesControllerProvider);
        categoryId = findCategoryIdByNames(
          catsState.parents,
          section.preferredCategoryNames,
        );
      }

      final res = await ref
          .read(adsApiProvider)
          .listAds(
            locationId: market.locationId,
            categoryId: categoryId,
            sort: section.sort,
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

    final discoverRes = await ref
        .read(adsApiProvider)
        .listAds(
          locationId: market.locationId,
          limit: _discoverLimit,
          offset: _offset,
        );

    final discoverItems = discoverRes.fold<List>(
      (_) => [],
      (payload) => payload['data']?['items'] ?? [],
    );

    return initialState.copyWith(
      sectionItems: sectionResults.map(
        (k, v) => MapEntry(k, v.map((e) => AOSAdListItem.fromJson(e)).toList()),
      ),
      discoverItems: discoverItems
          .map((e) => AOSAdListItem.fromJson(e))
          .toList(),
      initialLoading: false,
      hasMore: discoverItems.length == _discoverLimit,
    );
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
}
