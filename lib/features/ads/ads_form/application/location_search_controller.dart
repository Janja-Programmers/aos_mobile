import 'dart:async';

import 'package:africaonlinestores/features/ads/ads_form/application/location_search_state.dart';
import 'package:africaonlinestores/features/ads/ads_form/domain/ad_location_page.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final locationSearchControllerProvider =
    StateNotifierProvider.autoDispose<
      LocationSearchController,
      LocationSearchState
    >((ref) {
      return LocationSearchController(ref.read(adsApiProvider));
    });

class LocationSearchController extends StateNotifier<LocationSearchState> {
  LocationSearchController(this._repository)
    : super(const LocationSearchState());

  final AdLocationRepository _repository;

  static const Duration _searchDebounce = Duration(milliseconds: 300);

  Timer? _debounce;
  Future<void>? _initialRequest;
  String? _initialRequestQuery;
  int _requestGeneration = 0;

  Future<void> loadInitial() {
    final Future<void>? activeRequest = _initialRequest;
    if (activeRequest != null && _initialRequestQuery == state.query) {
      return activeRequest;
    }

    final String query = state.query;
    late final Future<void> request;
    request = _loadInitial().whenComplete(() {
      if (identical(_initialRequest, request)) {
        _initialRequest = null;
        _initialRequestQuery = null;
      }
    });
    _initialRequest = request;
    _initialRequestQuery = query;
    return request;
  }

  Future<void> _loadInitial() async {
    final int generation = ++_requestGeneration;
    final String query = state.query;

    state = state.copyWith(
      items: const <AdLocation>[],
      isLoadingInitial: true,
      isLoadingMore: false,
      hasMore: true,
      nextOffset: 0,
      clearError: true,
    );

    final result = await _repository.getLocations(
      query: query.isEmpty ? null : query,
    );

    if (!mounted || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingInitial: false,
          isLoadingMore: false,
          hasMore: false,
          error: failure,
        );
      },
      (page) {
        state = state.copyWith(
          items: _deduplicate(page.items),
          isLoadingInitial: false,
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextOffset: page.nextOffset ?? page.offset + page.items.length,
          clearError: true,
        );
      },
    );
  }

  void updateQuery(String value) {
    final bool changed = _setQuery(value);
    if (!changed) return;

    _debounce = Timer(_searchDebounce, loadInitial);
  }

  Future<void> search(String value) {
    _setQuery(value);
    return loadInitial();
  }

  bool _setQuery(String value) {
    final String query = value.trim();
    if (query == state.query) return false;

    _debounce?.cancel();
    _requestGeneration++;
    state = state.copyWith(
      query: query,
      items: const <AdLocation>[],
      isLoadingInitial: true,
      isLoadingMore: false,
      hasMore: true,
      nextOffset: 0,
      clearError: true,
    );
    return true;
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    final int generation = _requestGeneration;
    final String query = state.query;
    final int offset = state.nextOffset;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    final result = await _repository.getLocations(
      query: query.isEmpty ? null : query,
      offset: offset,
    );

    if (!mounted || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingMore: false, error: failure);
      },
      (page) {
        state = state.copyWith(
          items: _deduplicate(<AdLocation>[...state.items, ...page.items]),
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextOffset: page.nextOffset ?? page.offset + page.items.length,
          clearError: true,
        );
      },
    );
  }

  Future<void> retry() {
    return loadInitial();
  }

  List<AdLocation> _deduplicate(Iterable<AdLocation> locations) {
    final Map<String, AdLocation> byId = <String, AdLocation>{};
    for (final AdLocation location in locations) {
      if (location.id.isEmpty || location.name.isEmpty) continue;
      byId[location.id] = location;
    }
    return List<AdLocation>.unmodifiable(byId.values);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
