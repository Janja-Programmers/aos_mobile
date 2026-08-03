import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/seller_controller.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/seller_state_controller.dart';
import 'package:africaonlinestores/features/sellers/application/state/seller_list_state.dart';
import 'package:africaonlinestores/features/sellers/domain/seller_list_item.dart';
import 'package:flutter_riverpod/legacy.dart';

final sellerListControllerProvider =
    StateNotifierProvider.autoDispose<SellerListController, SellerListState>((
      ref,
    ) {
      return SellerListController(ref.read(sellerControllerProvider));
    });

class SellerListController extends StateNotifier<SellerListState> {
  SellerListController(this._sellerController) : super(const SellerListState());

  final SellerController _sellerController;

  Timer? _searchDebounce;
  int _requestSerial = 0;

  static const int _limit = 20;

  Future<void> loadInitial() async {
    final serial = ++_requestSerial;
    state = state.copyWith(
      isLoadingInitial: true,
      isLoadingMore: false,
      clearError: true,
      offset: 0,
      hasMore: true,
    );

    final search = state.search;
    final result = await _sellerController.listSellers(
      search: search,
      isVerified: 1,
    );

    if (!mounted || serial != _requestSerial || search != state.search) return;

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingInitial: false, error: failure);
      },
      (data) {
        final parsed = _parseResponse(data);

        state = state.copyWith(
          items: _deduplicate(parsed.items),
          isLoadingInitial: false,
          offset: parsed.items.length,
          limit: parsed.limit,
          hasMore: parsed.items.length >= parsed.limit,
          clearError: true,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    final serial = _requestSerial;
    final search = state.search;
    final offset = state.offset;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    final result = await _sellerController.listSellers(
      search: search,
      isVerified: 1,
      limit: state.limit,
      offset: offset,
    );

    if (!mounted ||
        serial != _requestSerial ||
        search != state.search ||
        offset != state.offset) {
      return;
    }

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingMore: false, error: failure);
      },
      (data) {
        final parsed = _parseResponse(data);

        final nextItems = _deduplicate([...state.items, ...parsed.items]);

        state = state.copyWith(
          items: nextItems,
          isLoadingMore: false,
          offset: offset + parsed.items.length,
          limit: parsed.limit,
          hasMore: parsed.items.length >= parsed.limit,
          clearError: true,
        );
      },
    );
  }

  void updateSearch(String value) {
    final normalized = value.trim();
    if (normalized == state.search) return;

    ++_requestSerial;
    state = state.copyWith(search: normalized, clearError: true);

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), loadInitial);
  }

  Future<void> retry() {
    return loadInitial();
  }

  List<SellerListItem> _deduplicate(List<SellerListItem> items) {
    final byUser = <String, SellerListItem>{};
    for (final item in items) {
      final key = item.user.trim();
      if (key.isEmpty) continue;
      byUser[key] = item;
    }
    return byUser.values.toList(growable: false);
  }

  _ParsedSellerListResponse _parseResponse(Map<String, dynamic> data) {
    final payload = asJsonMap(data['data']);

    if (payload.isEmpty) {
      return const _ParsedSellerListResponse(items: [], limit: _limit);
    }

    final items = asJsonMapList(
      payload['items'],
    ).map(SellerListItem.fromJson).toList();

    final limit = int.tryParse(payload['limit']?.toString() ?? '') ?? _limit;

    return _ParsedSellerListResponse(items: items, limit: limit);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

class _ParsedSellerListResponse {
  const _ParsedSellerListResponse({required this.items, required this.limit});

  final List<SellerListItem> items;
  final int limit;
}
