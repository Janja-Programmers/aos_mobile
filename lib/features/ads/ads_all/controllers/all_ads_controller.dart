import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_params.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_state.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AllAdsController extends StateNotifier<AllAdsState> {
  AllAdsController(this.ref, this.params) : super(const AllAdsState()) {
    unawaited(Future<void>.microtask(_init));
  }

  final Ref ref;
  final AllAdsParams params;

  static const _limit = 20;
  int _offset = 0;
  int _requestGeneration = 0;

  Timer? _wishlistSearchDebounce;
  bool _bootstrapped = false;

  bool get isWishlist => params.mode == AllAdsMode.wishlist;

  List<Map<String, dynamic>> _allCategories = [];

  /// Initialize controller from screen navigation
  Future<void> _init() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    state = state.copyWith(
      selectedCategoryId: params.initialCategoryId,
      selectedDealType: params.dealType,
      selectedSort: params.sort,
    );

    if (!isWishlist) {
      await _loadAllCategories();
      _resolveChildren();
    }

    await load(initial: true);
  }

  void _resolveChildren() {
    final selected = state.selectedCategoryId;

    // ✅ CASE 1: No category selected
    if (selected == null) {
      final parentId = params.parentCategoryId;

      // 🔥 FIX: if parent is ALSO null → show root categories
      if (parentId == null) {
        state = state.copyWith(
          children: _allCategories.map(CategoryNode.fromJson).toList(),
        );
        return;
      }

      // Normal parent → show its children
      final parentNode = _allCategories.firstWhere(
        (Map<String, dynamic> item) => item['id'] == parentId,
        orElse: () => <String, dynamic>{},
      );

      if (parentNode.isNotEmpty) {
        final children = asJsonMapList(parentNode['children']);

        state = state.copyWith(
          children: children.map(CategoryNode.fromJson).toList(),
        );
      } else {
        state = state.copyWith(children: []);
      }

      return;
    }

    // ✅ CASE 2: Selected is a parent → show its children
    final parent = _allCategories.firstWhere(
      (Map<String, dynamic> item) => item['id'] == selected,
      orElse: () => <String, dynamic>{},
    );

    if (parent.isNotEmpty) {
      final children = asJsonMapList(parent['children']);

      state = state.copyWith(
        children: children.map(CategoryNode.fromJson).toList(),
      );
      return;
    }

    // ✅ CASE 3: Selected is a child → show siblings
    for (final p in _allCategories) {
      final children = asJsonMapList(p['children']);

      final match = children.firstWhere(
        (Map<String, dynamic> child) => child['id'] == selected,
        orElse: () => <String, dynamic>{},
      );

      if (match.isNotEmpty) {
        state = state.copyWith(
          children: children.map(CategoryNode.fromJson).toList(),
        );
        return;
      }
    }

    // ✅ Fallback
    state = state.copyWith(children: []);
  }

  Future<void> _loadAllCategories() async {
    final api = ref.read(categoriesApiProvider);

    final res = await api.getCategories();

    res.fold((_) {}, (data) {
      _allCategories = asJsonMapList(data['data']);
    });
  }

  Future<void> load({bool initial = false}) async {
    if (state.loading || state.loadingMore) return;
    if (!state.hasMore && !initial) return;

    final requestGeneration = _requestGeneration;

    state = state.copyWith(
      loading: initial,
      loadingMore: !initial,
      clearError: true,
    );

    final api = ref.read(adsApiProvider);

    final categoryId = state.selectedCategoryId;
    final dealType = state.selectedDealType.apiValue;
    final sort = state.selectedSort?.apiValue;
    final wishlistQuery = state.wishlistQuery.trim();

    final res = isWishlist
        ? await api.listWishlist(
            offset: _offset,
            sort: sort,
            q: wishlistQuery.isEmpty ? null : wishlistQuery,
            priceMin: state.wishlistMinPrice,
            priceMax: state.wishlistMaxPrice,
            ratingMin: state.wishlistMinRating,
            verifiedSeller: switch (state.wishlistVerifiedSellers) {
              true => true,
              false => null,
            },
          )
        : await api.listAds(
            categoryId: categoryId,
            promotionType: dealType,
            sort: sort,
            offset: _offset,
          );

    if (!mounted || requestGeneration != _requestGeneration) {
      return;
    }

    res.fold(
      (failure) {
        state = state.copyWith(
          loading: false,
          loadingMore: false,
          error: failure.message,
        );
      },
      (data) {
        final responseData = asJsonMap(data['data']);
        final list = asJsonMapList(
          responseData['items'],
        ).map(AOSAdListItem.fromJson).toList();
        final pagination = asJsonMap(responseData['pagination']);
        final hasMore = pagination.isEmpty
            ? list.length == _limit
            : asBool(pagination['has_more']);
        final nextOffset = asNullableInt(pagination['next_offset']);

        final merged = _offset == 0 ? list : [...state.items, ...list];

        _offset = nextOffset ?? (_offset + list.length);

        state = state.copyWith(
          items: merged,
          hasMore: hasMore,
          loading: false,
          loadingMore: false,
          clearError: true,
        );
      },
    );
  }

  Future<void> refresh() async {
    _invalidateActiveRequest();
    _offset = 0;

    state = state.copyWith(hasMore: true, items: [], clearError: true);

    await load(initial: true);
  }

  void toggleView() {
    state = state.copyWith(
      view: state.view == ViewMode.grid ? ViewMode.list : ViewMode.grid,
    );
  }

  void setCategory(String? id) {
    if (isWishlist) return;

    final nextId = id;
    if (state.selectedCategoryId == nextId) return;

    _invalidateActiveRequest();
    _offset = 0;

    state = state.copyWith(
      selectedCategoryId: nextId,
      items: [],
      hasMore: true,
    );

    _resolveChildren();

    unawaited(load(initial: true));
  }

  void setDealType(DealType type) {
    if (isWishlist || state.selectedDealType == type) return;

    _invalidateActiveRequest();
    _offset = 0;

    state = state.copyWith(selectedDealType: type, items: [], hasMore: true);

    unawaited(load(initial: true));
  }

  void setSortType(AdsSort? sortType) {
    if (state.selectedSort == sortType) return;

    _invalidateActiveRequest();
    _offset = 0;

    state = state.copyWith(selectedSort: sortType, items: [], hasMore: true);

    unawaited(load(initial: true));
  }

  void setWishlistSearch(String query) {
    if (!isWishlist) return;

    final clean = query.trim();
    if (clean == state.wishlistQuery) return;

    _wishlistSearchDebounce?.cancel();
    _invalidateActiveRequest();

    state = state.copyWith(wishlistQuery: clean, clearError: true);

    // The backend accepts either an empty query or at least two characters.
    // Keep the current results while the user has typed only one character.
    if (clean.length == 1) return;

    _offset = 0;
    state = state.copyWith(
      items: [],
      hasMore: true,
      loading: true,
      clearError: true,
    );

    _wishlistSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      state = state.copyWith(loading: false);
      unawaited(load(initial: true));
    });
  }

  void applyWishlistFilters({
    int? priceMin,
    int? priceMax,
    int? ratingMin,
    bool verifiedSellers = false,
  }) {
    if (!isWishlist) return;

    final unchanged =
        state.wishlistMinPrice == priceMin &&
        state.wishlistMaxPrice == priceMax &&
        state.wishlistMinRating == ratingMin &&
        state.wishlistVerifiedSellers == verifiedSellers;
    if (unchanged) return;

    _invalidateActiveRequest();
    _offset = 0;
    state = state.copyWith(
      wishlistMinPrice: priceMin,
      wishlistMaxPrice: priceMax,
      wishlistMinRating: ratingMin,
      wishlistVerifiedSellers: verifiedSellers,
      items: [],
      hasMore: true,
      clearError: true,
    );

    unawaited(load(initial: true));
  }

  void _invalidateActiveRequest() {
    _requestGeneration += 1;
    state = state.copyWith(loading: false, loadingMore: false);
  }

  void clearWishlistFilters() {
    applyWishlistFilters();
  }

  @override
  void dispose() {
    _wishlistSearchDebounce?.cancel();
    super.dispose();
  }
}
