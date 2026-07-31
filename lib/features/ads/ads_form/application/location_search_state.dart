import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/features/ads/ads_form/domain/ad_location_page.dart';

class LocationSearchState {
  const LocationSearchState({
    this.items = const <AdLocation>[],
    this.query = '',
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextOffset = 0,
    this.error,
  });

  final List<AdLocation> items;
  final String query;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final int nextOffset;
  final Failure? error;

  bool get canLoadMore => hasMore && !isLoadingInitial && !isLoadingMore;

  LocationSearchState copyWith({
    List<AdLocation>? items,
    String? query,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMore,
    int? nextOffset,
    Failure? error,
    bool clearError = false,
  }) {
    return LocationSearchState(
      items: items ?? this.items,
      query: query ?? this.query,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
      error: clearError ? null : error ?? this.error,
    );
  }
}
