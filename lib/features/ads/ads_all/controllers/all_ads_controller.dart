import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_params.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_state.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_state.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AllAdsController extends StateNotifier<AllAdsState> {
  AllAdsController(this.ref, this.params) : super(const AllAdsState()) {
    if (isWishlist) {
      ref.listen<WishlistState>(wishlistControllerProvider, (previous, next) {
        if (!mounted) return;
        _reconcileWishlistMembership(next);
      });
    }

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
  bool get isSellerStorefront => params.sellerId?.trim().isNotEmpty ?? false;

  List<CategoryNode> _allCategories = <CategoryNode>[];
  final Map<String, _HiddenWishlistItem> _hiddenWishlistItems =
      <String, _HiddenWishlistItem>{};

  /// Initialize controller from screen navigation.
  Future<void> _init() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    state = state.copyWith(
      selectedCategoryId: params.initialCategoryId,
      selectedDealType: params.dealType,
      selectedSort: params.sort,
    );

    // Seller storefronts already have a fixed seller scope and do not need the
    // category tree just to render their product list.
    if (!isWishlist && !isSellerStorefront) {
      await _loadAllCategories();
      if (!mounted) return;
      _resolveChildren();
    }

    if (!mounted) return;
    await load(initial: true);
  }

  void _resolveChildren() {
    final selected = state.selectedCategoryId;

    if (selected == null) {
      final parentId = params.parentCategoryId;
      if (parentId == null) {
        state = state.copyWith(children: _allCategories);
        return;
      }

      final CategoryNode? parentNode = _rootById(parentId);
      if (parentNode != null) {
        state = state.copyWith(children: parentNode.children);
      } else {
        state = state.copyWith(children: []);
      }
      return;
    }

    final CategoryNode? parent = _rootById(selected);
    if (parent != null) {
      state = state.copyWith(children: parent.children);
      return;
    }

    for (final CategoryNode root in _allCategories) {
      final bool containsSelected = root.children.any(
        (CategoryNode child) => child.id == selected,
      );
      if (containsSelected) {
        state = state.copyWith(children: root.children);
        return;
      }
    }

    state = state.copyWith(children: []);
  }

  Future<void> _loadAllCategories() async {
    final repository = ref.read(categoriesRepositoryProvider);
    final res = await repository.getCategories();

    if (!mounted) return;

    final List<CategoryNode>? categories = res.rightOrNull;
    if (categories != null) {
      _allCategories = categories;
    }
  }

  CategoryNode? _rootById(String id) {
    for (final CategoryNode root in _allCategories) {
      if (root.id == id) return root;
    }
    return null;
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
            priceMin: state.filterMinPrice,
            priceMax: state.filterMaxPrice,
            ratingMin: state.filterMinRating,
            verifiedSeller: switch (state.filterVerifiedSellers) {
              true => true,
              false => null,
            },
          )
        : await api.listAds(
            sellerId: params.sellerId,
            categoryId: categoryId,
            promotionType: dealType,
            sort: sort,
            priceMin: state.filterMinPrice?.toDouble(),
            priceMax: state.filterMaxPrice?.toDouble(),
            ratingMin: state.filterMinRating?.toDouble(),
            offset: _offset,
          );

    if (!mounted || requestGeneration != _requestGeneration) return;

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
        final returned = asInt(pagination['returned'], fallback: list.length);
        final hasMore = pagination.containsKey('has_more')
            ? asBool(pagination['has_more'])
            : returned >= _limit;
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

        if (isWishlist) {
          _reconcileWishlistMembership(ref.read(wishlistControllerProvider));
        }
      },
    );
  }

  Future<void> refresh() async {
    _invalidateActiveRequest();
    _offset = 0;
    _hiddenWishlistItems.clear();

    state = state.copyWith(hasMore: true, items: [], clearError: true);
    await load(initial: true);
  }

  void toggleView() {
    state = state.copyWith(
      view: state.view == ViewMode.grid ? ViewMode.list : ViewMode.grid,
    );
  }

  void setCategory(String? id) {
    if (isWishlist || isSellerStorefront) return;
    if (state.selectedCategoryId == id) return;

    _invalidateActiveRequest();
    _offset = 0;

    state = state.copyWith(selectedCategoryId: id, items: [], hasMore: true);

    _resolveChildren();
    unawaited(load(initial: true));
  }

  void setDealType(DealType type) {
    if (isWishlist || isSellerStorefront || state.selectedDealType == type) {
      return;
    }

    _invalidateActiveRequest();
    _offset = 0;
    state = state.copyWith(selectedDealType: type, items: [], hasMore: true);
    unawaited(load(initial: true));
  }

  void setSortType(AdsSort? sortType) {
    if (state.selectedSort == sortType) return;

    _invalidateActiveRequest();
    _offset = 0;
    _hiddenWishlistItems.clear();

    state = state.copyWith(selectedSort: sortType, items: [], hasMore: true);
    unawaited(load(initial: true));
  }

  void setWishlistSearch(String query) {
    if (!isWishlist) return;

    final clean = query.trim();
    if (clean == state.wishlistQuery) return;

    _wishlistSearchDebounce?.cancel();
    _invalidateActiveRequest();
    _hiddenWishlistItems.clear();

    state = state.copyWith(wishlistQuery: clean, clearError: true);

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

  /// Applies backend-supported list filters in the current discovery scope.
  /// Verified-seller filtering is only available on the wishlist endpoint;
  /// seller storefronts already have a fixed seller identity.
  void applyFilters({
    int? priceMin,
    int? priceMax,
    int? ratingMin,
    bool verifiedSellers = false,
  }) {
    final effectiveVerified = isWishlist && verifiedSellers;
    final unchanged =
        state.filterMinPrice == priceMin &&
        state.filterMaxPrice == priceMax &&
        state.filterMinRating == ratingMin &&
        state.filterVerifiedSellers == effectiveVerified;
    if (unchanged) return;

    _invalidateActiveRequest();
    _offset = 0;
    _hiddenWishlistItems.clear();
    state = state.copyWith(
      filterMinPrice: priceMin,
      filterMaxPrice: priceMax,
      filterMinRating: ratingMin,
      filterVerifiedSellers: effectiveVerified,
      items: [],
      hasMore: true,
      clearError: true,
    );

    unawaited(load(initial: true));
  }

  void resetSortAndFilters() {
    final alreadyReset = state.selectedSort == null && !state.hasFilters;
    if (alreadyReset) return;

    _invalidateActiveRequest();
    _offset = 0;
    _hiddenWishlistItems.clear();
    state = state.copyWith(
      selectedSort: null,
      filterMinPrice: null,
      filterMaxPrice: null,
      filterMinRating: null,
      filterVerifiedSellers: false,
      items: [],
      hasMore: true,
      clearError: true,
    );
    unawaited(load(initial: true));
  }

  void _reconcileWishlistMembership(WishlistState wishlistState) {
    if (!mounted || !isWishlist) return;

    final items = List<AOSAdListItem>.from(state.items);
    var changed = false;

    for (var index = items.length - 1; index >= 0; index -= 1) {
      final ad = items[index];
      final shouldRemainVisible = wishlistState.resolve(
        ad.id,
        fallback: ad.isWishlisted,
      );
      if (shouldRemainVisible) continue;

      if (!_hiddenWishlistItems.containsKey(ad.id)) {
        final previousId = index > 0 ? items[index - 1].id : null;
        final nextId = index + 1 < items.length ? items[index + 1].id : null;
        final offsetAdjusted = _offset > 0;
        if (offsetAdjusted) _offset -= 1;

        _hiddenWishlistItems[ad.id] = _HiddenWishlistItem(
          item: ad,
          originalIndex: index,
          previousId: previousId,
          nextId: nextId,
          offsetAdjusted: offsetAdjusted,
        );
      }

      items.removeAt(index);
      changed = true;
    }

    for (final entry in _hiddenWishlistItems.entries.toList(growable: false)) {
      final id = entry.key;
      final snapshot = entry.value;
      final shouldBeVisible = wishlistState.resolve(
        id,
        fallback: snapshot.item.isWishlisted,
      );
      if (!shouldBeVisible) continue;

      if (!items.any((item) => item.id == id)) {
        final insertionIndex = _restoreIndex(items, snapshot);
        items.insert(insertionIndex, snapshot.item);
        if (snapshot.offsetAdjusted) _offset += 1;
        changed = true;
      }

      _hiddenWishlistItems.remove(id);
    }

    if (changed) {
      state = state.copyWith(items: items);
    }
  }

  int _restoreIndex(List<AOSAdListItem> items, _HiddenWishlistItem snapshot) {
    final nextId = snapshot.nextId;
    if (nextId != null) {
      final nextIndex = items.indexWhere((item) => item.id == nextId);
      if (nextIndex >= 0) return nextIndex;
    }

    final previousId = snapshot.previousId;
    if (previousId != null) {
      final previousIndex = items.indexWhere((item) => item.id == previousId);
      if (previousIndex >= 0) return previousIndex + 1;
    }

    return snapshot.originalIndex > items.length
        ? items.length
        : snapshot.originalIndex;
  }

  void _invalidateActiveRequest() {
    _requestGeneration += 1;
    state = state.copyWith(loading: false, loadingMore: false);
  }

  void clearFilters() {
    applyFilters();
  }

  @override
  void dispose() {
    _wishlistSearchDebounce?.cancel();
    super.dispose();
  }
}

class _HiddenWishlistItem {
  const _HiddenWishlistItem({
    required this.item,
    required this.originalIndex,
    required this.previousId,
    required this.nextId,
    required this.offsetAdjusted,
  });

  final AOSAdListItem item;
  final int originalIndex;
  final String? previousId;
  final String? nextId;
  final bool offsetAdjusted;
}
