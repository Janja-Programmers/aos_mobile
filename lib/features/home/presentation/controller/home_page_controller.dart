import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_sections.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_state.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

final homePageControllerProvider =
    AsyncNotifierProvider<HomePageController, HomePageState>(
      HomePageController.new,
    );

class HomePageController extends AsyncNotifier<HomePageState> {
  static const int _discoverLimit = 20;

  int _offset = 0;
  bool _initializing = false;
  String? _lastMarketKey;

  @override
  Future<HomePageState> build() async {
    final prefs = ref.watch(userPreferenceControllerProvider);

    final countryCode = prefs.countryCode;

    final marketKey = '${countryCode.toUpperCase()}.';

    if (state.hasValue && _lastMarketKey == marketKey) {
      return state.value!;
    }

    _lastMarketKey = marketKey;
    _offset = 0;

    return _loadInitial(countryCode: countryCode);
  }

  List<AOSAdListItem> _parseItems(Map<String, dynamic> payload) {
    final raw = payload['data']?['items'];
    if (raw is! List) return const [];

    return raw
        .map((e) => AOSAdListItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<HomePageState> _loadInitial({
    required String countryCode,
    String? locationId,
  }) async {
    if (_initializing) {
      return state.value ?? HomePageState.initial(homeAdsSections);
    }

    _initializing = true;

    try {
      final initialState = HomePageState.initial(homeAdsSections);
      final sectionResults = <String, List<AOSAdListItem>>{};

      await Future.wait(
        homeAdsSections.map((section) async {
          final categoryId = section.preferredCategoryNames.isNotEmpty
              ? section.preferredCategoryNames.first
              : null;

          final res = await ref
              .read(adsApiProvider)
              .listAds(
                locationId: locationId,
                categoryId: categoryId,
                sort: section.sort,
                promotionType: section.promotionType,
                limit: section.limit,
                offset: 0,
              );

          final items = res.fold<List<AOSAdListItem>>(
            (_) => const [],
            (payload) => _parseItems(Map<String, dynamic>.from(payload)),
          );

          sectionResults[section.key] = items;
        }),
      );

      final discoverRes = await ref
          .read(adsApiProvider)
          .listAds(locationId: locationId, limit: _discoverLimit, offset: 0);

      final discoverItems = discoverRes.fold<List<AOSAdListItem>>(
        (_) => const [],
        (payload) => _parseItems(Map<String, dynamic>.from(payload)),
      );

      return initialState.copyWith(
        sectionItems: sectionResults,
        discoverItems: discoverItems,
        initialLoading: false,
        loadingMore: false,
        hasMore: discoverItems.length == _discoverLimit,
      );
    } finally {
      _initializing = false;
    }
  }

  Future<void> changeLocation(String? locationId) async {
    final current = state.value;

    if (current?.locationId == locationId) return;

    final prefs = ref.read(userPreferenceControllerProvider);

    _offset = 0;

    state = const AsyncLoading();

    final next = await _loadInitial(
      countryCode: prefs.countryCode,
      locationId: locationId,
    );

    state = AsyncData(next.copyWith(locationId: locationId));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));

    _offset = current.discoverItems.length;

    final locationId = state.value?.locationId;

    final res = await ref
        .read(adsApiProvider)
        .listAds(
          locationId: locationId,
          limit: _discoverLimit,
          offset: _offset,
        );

    final parsed = res.fold<List<AOSAdListItem>>(
      (_) => const [],
      (payload) => _parseItems(Map<String, dynamic>.from(payload)),
    );

    final latest = state.value ?? current;

    state = AsyncData(
      latest.copyWith(
        discoverItems: [...latest.discoverItems, ...parsed],
        loadingMore: false,
        hasMore: parsed.length == _discoverLimit,
      ),
    );
  }

  Future<void> refresh() async {
    final prefs = ref.read(userPreferenceControllerProvider);

    _offset = 0;
    state = const AsyncLoading();

    final next = await _loadInitial(
      countryCode: prefs.countryCode,
      locationId: state.value?.locationId,
    );

    state = AsyncData(next);
  }
}
