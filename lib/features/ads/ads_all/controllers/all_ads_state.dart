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
    this.filterMinPrice,
    this.filterMaxPrice,
    this.filterMinRating,
    this.filterVerifiedSellers = false,
  });

  final List<AOSAdListItem> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;

  final ViewMode view;

  /// Active category pill.
  final String? selectedCategoryId;

  /// Active deals pill.
  final DealType selectedDealType;

  final AdsSort? selectedSort;

  /// Children of parent category.
  final List<CategoryNode> children;

  /// Wishlist-only search query. Discovery filters are shared by any
  /// list context that the backend supports, including seller storefronts.
  final String wishlistQuery;
  final int? filterMinPrice;
  final int? filterMaxPrice;
  final int? filterMinRating;
  final bool filterVerifiedSellers;

  bool get hasFilters {
    return filterMinPrice != null ||
        filterMaxPrice != null ||
        filterMinRating != null ||
        filterVerifiedSellers;
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
    Object? filterMinPrice = _unset,
    Object? filterMaxPrice = _unset,
    Object? filterMinRating = _unset,
    bool? filterVerifiedSellers,
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
      filterMinPrice: filterMinPrice == _unset
          ? this.filterMinPrice
          : filterMinPrice as int?,
      filterMaxPrice: filterMaxPrice == _unset
          ? this.filterMaxPrice
          : filterMaxPrice as int?,
      filterMinRating: filterMinRating == _unset
          ? this.filterMinRating
          : filterMinRating as int?,
      filterVerifiedSellers:
          filterVerifiedSellers ?? this.filterVerifiedSellers,
    );
  }
}
