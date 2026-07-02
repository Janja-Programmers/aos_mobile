import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/features/sellers/domain/seller_list_item.dart';
import 'package:equatable/equatable.dart';

class SellerListState extends Equatable {
  const SellerListState({
    this.items = const [],
    this.search = '',
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.limit = 20,
    this.offset = 0,
  });

  final List<SellerListItem> items;
  final String search;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final Failure? error;
  final int limit;
  final int offset;

  bool get isEmpty => items.isEmpty && !isLoadingInitial;
  bool get canLoadMore => hasMore && !isLoadingInitial && !isLoadingMore;

  SellerListState copyWith({
    List<SellerListItem>? items,
    String? search,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMore,
    Failure? error,
    bool clearError = false,
    int? limit,
    int? offset,
  }) {
    return SellerListState(
      items: items ?? this.items,
      search: search ?? this.search,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
    items,
    search,
    isLoadingInitial,
    isLoadingMore,
    hasMore,
    error,
    limit,
    offset,
  ];
}
