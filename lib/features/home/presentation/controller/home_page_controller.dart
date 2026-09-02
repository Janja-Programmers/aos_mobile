import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/catalog/domain/categories_state.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_sections.dart';
import 'package:africaonlinestores/features/home/domain/home_category_selection.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_state.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homePageControllerProvider =
    AsyncNotifierProvider<HomePageController, HomePageState>(
      HomePageController.new,
    );

class HomePageController extends AsyncNotifier<HomePageState> {
  static const int _discoverLimit = 20;

  final String _sessionSeed = DateTime.now().microsecondsSinceEpoch
      .toRadixString(36);
  final Map<String, Future<List<AOSAdListItem>>> _inFlightRequests =
      <String, Future<List<AOSAdListItem>>>{};

  int _requestGeneration = 0;
  int _categorySelectionEpoch = 0;
  String? _lastMarketKey;
  String? _lastCategorySignature;

  @override
  Future<HomePageState> build() async {
    final UserPreferenceState preferences = ref.watch(
      userPreferenceControllerProvider,
    );
    final CategoriesState categories = ref.watch(categoriesControllerProvider);

    final String marketKey = _marketKey(preferences);
    final String categorySignature = _categorySignature(categories.parents);
    final HomePageState? previous = state.value;
    final bool marketChanged =
        _lastMarketKey != null && _lastMarketKey != marketKey;
    final bool categoriesChanged =
        _lastCategorySignature != null &&
        _lastCategorySignature != categorySignature;

    _lastMarketKey = marketKey;
    _lastCategorySignature = categorySignature;

    if (previous == null || marketChanged) {
      if (marketChanged) {
        _categorySelectionEpoch = 0;
      }
      final int generation = ++_requestGeneration;
      final HomePageState next = await _loadInitial(
        locationId: previous?.locationId,
        parents: categories.parents,
        marketKey: marketKey,
      );
      if (generation != _requestGeneration && state.value != null) {
        return state.value!;
      }
      return next;
    }

    if (categoriesChanged &&
        !categories.loading &&
        categories.errorMessage == null) {
      return _loadCategorySections(
        base: previous,
        parents: categories.parents,
        marketKey: marketKey,
      );
    }

    return previous;
  }

  Future<void> changeLocation(String? locationId) async {
    final HomePageState? current = state.value;
    if (current == null || current.locationId == locationId) {
      return;
    }

    final UserPreferenceState preferences = ref.read(
      userPreferenceControllerProvider,
    );
    final CategoriesState categories = ref.read(categoriesControllerProvider);
    final int generation = ++_requestGeneration;

    state = AsyncData<HomePageState>(
      current.copyWith(initialLoading: true, loadingMore: false),
    );

    final HomePageState next = await _loadInitial(
      locationId: locationId,
      parents: categories.parents,
      marketKey: _marketKey(preferences),
    );

    if (generation != _requestGeneration) {
      return;
    }
    state = AsyncData<HomePageState>(next);
  }

  Future<void> loadMore() async {
    final HomePageState? current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) {
      return;
    }

    final int generation = _requestGeneration;
    final int offset = current.discoverItems.length;
    state = AsyncData<HomePageState>(current.copyWith(loadingMore: true));

    final List<AOSAdListItem> parsed = await _loadAds(
      locationId: current.locationId,
      offset: offset,
    );

    if (generation != _requestGeneration) {
      return;
    }

    final HomePageState latest = state.value ?? current;
    state = AsyncData<HomePageState>(
      latest.copyWith(
        discoverItems: <AOSAdListItem>[...latest.discoverItems, ...parsed],
        loadingMore: false,
        hasMore: parsed.length == _discoverLimit,
      ),
    );
  }

  Future<void> refresh() async {
    final HomePageState? current = state.value;
    if (current == null) {
      return;
    }

    final UserPreferenceState preferences = ref.read(
      userPreferenceControllerProvider,
    );
    final CategoriesState categories = ref.read(categoriesControllerProvider);
    final String marketKey = _marketKey(preferences);
    final int generation = ++_requestGeneration;

    _categorySelectionEpoch += 1;
    state = AsyncData<HomePageState>(
      current.copyWith(initialLoading: true, loadingMore: false),
    );

    final HomePageState next = await _loadInitial(
      locationId: current.locationId,
      parents: categories.parents,
      marketKey: marketKey,
    );

    if (generation != _requestGeneration) {
      return;
    }
    state = AsyncData<HomePageState>(next);
  }

  Future<HomePageState> _loadInitial({
    required String? locationId,
    required List<CategoryNode> parents,
    required String marketKey,
  }) async {
    final List<CategoryNode> selectedCategories = _selectCategories(
      parents,
      marketKey,
    );
    final List<HomeAdsSection> sections = buildHomeAdsSections(
      selectedCategories,
    );
    final Map<String, List<AOSAdListItem>> sectionResults =
        <String, List<AOSAdListItem>>{};

    await Future.wait<void>(<Future<void>>[
      for (final HomeAdsSection section in sections)
        _loadSectionInto(
          sectionResults,
          section: section,
          locationId: locationId,
        ),
    ]);

    final List<AOSAdListItem> discoverItems = await _loadAds(
      locationId: locationId,
    );

    return HomePageState.initial(
      sections,
      locationId: locationId,
      selectedCategories: selectedCategories,
    ).copyWith(
      sectionItems: Map<String, List<AOSAdListItem>>.unmodifiable(
        sectionResults,
      ),
      discoverItems: discoverItems,
      initialLoading: false,
      loadingMore: false,
      hasMore: discoverItems.length == _discoverLimit,
    );
  }

  Future<HomePageState> _loadCategorySections({
    required HomePageState base,
    required List<CategoryNode> parents,
    required String marketKey,
  }) async {
    final List<CategoryNode> selectedCategories = _selectCategories(
      parents,
      marketKey,
    );
    final List<HomeAdsSection> sections = buildHomeAdsSections(
      selectedCategories,
    );
    final Set<String> allowedKeys = sections
        .map((HomeAdsSection section) => section.key)
        .toSet();
    final Map<String, List<AOSAdListItem>> sectionItems =
        <String, List<AOSAdListItem>>{
          for (final MapEntry<String, List<AOSAdListItem>> entry
              in base.sectionItems.entries)
            if (allowedKeys.contains(entry.key)) entry.key: entry.value,
        };

    final List<Future<void>> requests = <Future<void>>[];
    for (final HomeAdsSection section in sections) {
      if (!section.isCategorySection || sectionItems.containsKey(section.key)) {
        continue;
      }
      requests.add(
        _loadSectionInto(
          sectionItems,
          section: section,
          locationId: base.locationId,
        ),
      );
    }
    await Future.wait<void>(requests);

    return base.copyWith(
      sections: sections,
      selectedCategories: selectedCategories,
      sectionItems: Map<String, List<AOSAdListItem>>.unmodifiable(sectionItems),
      initialLoading: false,
    );
  }

  Future<void> _loadSectionInto(
    Map<String, List<AOSAdListItem>> target, {
    required HomeAdsSection section,
    required String? locationId,
  }) async {
    target[section.key] = await _loadAds(
      locationId: locationId,
      categoryId: section.categoryId,
      sort: section.sort,
      promotionType: section.promotionType,
      limit: section.limit,
    );
  }

  Future<List<AOSAdListItem>> _loadAds({
    String? locationId,
    String? categoryId,
    String? sort,
    String? promotionType,
    int limit = 20,
    int offset = 0,
  }) {
    final String requestKey = <Object?>[
      locationId,
      categoryId,
      sort,
      promotionType,
      limit,
      offset,
    ].map((Object? value) => value?.toString() ?? '').join('\u001F');
    final Future<List<AOSAdListItem>>? existing = _inFlightRequests[requestKey];
    if (existing != null) {
      return existing;
    }

    final Future<List<AOSAdListItem>> request = _fetchAds(
      locationId: locationId,
      categoryId: categoryId,
      sort: sort,
      promotionType: promotionType,
      limit: limit,
      offset: offset,
    );
    _inFlightRequests[requestKey] = request;
    unawaited(
      request.whenComplete(() {
        if (identical(_inFlightRequests[requestKey], request)) {
          _inFlightRequests.remove(requestKey);
        }
      }),
    );
    return request;
  }

  Future<List<AOSAdListItem>> _fetchAds({
    required String? locationId,
    required String? categoryId,
    required String? sort,
    required String? promotionType,
    required int limit,
    required int offset,
  }) async {
    try {
      final result = await ref
          .read(adsApiProvider)
          .listAds(
            locationId: locationId,
            categoryId: categoryId,
            sort: sort,
            promotionType: promotionType,
            limit: limit,
            offset: offset,
          );

      return result.fold<List<AOSAdListItem>>((failure) {
        appLogger.w('[Home] Ads request failed: ${failure.message}');
        return const <AOSAdListItem>[];
      }, (payload) => _parseItems(asJsonMap(payload)));
    } on Exception catch (error) {
      appLogger.w('[Home] Failed to parse ads response: $error');
      return const <AOSAdListItem>[];
    }
  }

  List<AOSAdListItem> _parseItems(Map<String, dynamic> payload) {
    final Map<String, dynamic> data = asJsonMap(payload['data']);
    return asJsonMapList(
      data['items'],
    ).map(AOSAdListItem.fromJson).toList(growable: false);
  }

  List<CategoryNode> _selectCategories(
    List<CategoryNode> parents,
    String marketKey,
  ) {
    return selectHomeCategories(
      parents,
      seed: '$marketKey:$_sessionSeed:$_categorySelectionEpoch',
    );
  }

  String _marketKey(UserPreferenceState preferences) {
    final String countryId = preferences.countryId.trim();
    if (countryId.isNotEmpty) {
      return countryId;
    }
    return preferences.countryCode.trim().toUpperCase();
  }

  String _categorySignature(List<CategoryNode> parents) {
    return parents
        .map(
          (CategoryNode category) =>
              '${category.id}\u001F${category.name}\u001F${category.sortOrder}',
        )
        .join('\u001E');
  }
}
