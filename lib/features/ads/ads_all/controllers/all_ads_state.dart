import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';

const Object _unset = Object();

class AllAdsState {
  const AllAdsState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.error,
    this.view = ViewMode.grid,
    this.selectedCategoryId,
    this.selectedDealType = DealType.all,
    this.selectedSort,
    this.children = const [],
    this.wishlistQuery = '',
    this.wishlistMinPrice,
    this.wishlistMaxPrice,
    this.wishlistMinRating,
    this.wishlistVerifiedSellers = false,
    this.wishlistPreferredStore = false,
  });

  final List<AOSAdListItem> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;

  final ViewMode view;

  /// Active category pill
  final String? selectedCategoryId;

  /// Active deals pill
  final DealType selectedDealType;

  final AdsSort? selectedSort;

  /// Children of parent category
  final List<CategoryNode> children;

  /// Wishlist-only search and filters.
  final String wishlistQuery;
  final int? wishlistMinPrice;
  final int? wishlistMaxPrice;
  final int? wishlistMinRating;
  final bool wishlistVerifiedSellers;
  final bool wishlistPreferredStore;

  bool get hasWishlistFilters {
    return wishlistMinPrice != null ||
        wishlistMaxPrice != null ||
        wishlistMinRating != null ||
        wishlistVerifiedSellers ||
        wishlistPreferredStore;
  }

  AllAdsState copyWith({
    List<AOSAdListItem>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    ViewMode? view,
    Object? selectedCategoryId = _unset,
    DealType? selectedDealType,
    Object? selectedSort = _unset,
    List<CategoryNode>? children,
    String? wishlistQuery,
    Object? wishlistMinPrice = _unset,
    Object? wishlistMaxPrice = _unset,
    Object? wishlistMinRating = _unset,
    bool? wishlistVerifiedSellers,
    bool? wishlistPreferredStore,
  }) {
    return AllAdsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      view: view ?? this.view,
      selectedCategoryId: selectedCategoryId == _unset
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      selectedDealType: selectedDealType ?? this.selectedDealType,
      selectedSort: selectedSort == _unset
          ? this.selectedSort
          : selectedSort as AdsSort?,
      children: children ?? this.children,
      wishlistQuery: wishlistQuery ?? this.wishlistQuery,
      wishlistMinPrice: wishlistMinPrice == _unset
          ? this.wishlistMinPrice
          : wishlistMinPrice as int?,
      wishlistMaxPrice: wishlistMaxPrice == _unset
          ? this.wishlistMaxPrice
          : wishlistMaxPrice as int?,
      wishlistMinRating: wishlistMinRating == _unset
          ? this.wishlistMinRating
          : wishlistMinRating as int?,
      wishlistVerifiedSellers:
          wishlistVerifiedSellers ?? this.wishlistVerifiedSellers,
      wishlistPreferredStore:
          wishlistPreferredStore ?? this.wishlistPreferredStore,
    );
  }
}
