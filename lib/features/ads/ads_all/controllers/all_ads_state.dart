import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

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

  AllAdsState copyWith({
    List<AOSAdListItem>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? error,
    ViewMode? view,
    String? selectedCategoryId,
    DealType? selectedDealType,
    AdsSort? selectedSort,
    List<CategoryNode>? children,
  }) {
    return AllAdsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      view: view ?? this.view,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedDealType: selectedDealType ?? this.selectedDealType,
      selectedSort: selectedSort ?? this.selectedSort,
      children: children ?? this.children,
    );
  }
}
