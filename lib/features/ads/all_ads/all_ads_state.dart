import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

enum ViewMode { grid, list }

class AllAdsState {
  const AllAdsState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.error,
    this.view = ViewMode.grid,
    this.selectedCategoryId,
    this.children = const [],
  });

  final List<AOSAdListItem> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;

  final ViewMode view;
  final String? selectedCategoryId;

  final List<CategoryNode> children;

  AllAdsState copyWith({
    List<AOSAdListItem>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? error,
    ViewMode? view,
    String? selectedCategoryId,
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
      children: children ?? this.children,
    );
  }
}
