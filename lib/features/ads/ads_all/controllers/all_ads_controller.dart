import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_state.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

class AllAdsController extends StateNotifier<AllAdsState> {
  AllAdsController(this.ref) : super(const AllAdsState());

  final Ref ref;

  static const _limit = 20;
  int _offset = 0;

  String? _parentCategoryId;
  AllAdsMode _mode = AllAdsMode.normal;

  bool get isWishlist => _mode == AllAdsMode.wishlist;

  bool _initialized = false;

  /// Initialize controller from screen navigation
  Future<void> init({
    String? parentCategoryId,
    String? initialCategoryId,
    DealType dealType = DealType.all,
    AllAdsMode mode = AllAdsMode.normal,
  }) async {
    if (_initialized) return;

    _initialized = true;

    _parentCategoryId = parentCategoryId;
    _mode = mode;

    state = state.copyWith(
      selectedCategoryId: initialCategoryId,
      selectedDealType: dealType,
    );

    await load(initial: true);
  }

  Future<void> load({bool initial = false}) async {
    if (state.loading || state.loadingMore) return;
    if (!state.hasMore && !initial) return;

    state = state.copyWith(
      loading: initial,
      loadingMore: !initial,
      error: null,
    );

    final api = ref.read(adsApiProvider);

    final categoryId = state.selectedCategoryId ?? _parentCategoryId;
    final dealType = state.selectedDealType.apiValue;

    final res = isWishlist
        ? await api.listWishlist(limit: _limit, offset: _offset)
        : await api.listAds(
            categoryId: categoryId,
            promotionType: dealType,
            limit: _limit,
            offset: _offset,
          );

    res.fold(
      (failure) {
        state = state.copyWith(
          loading: false,
          loadingMore: false,
          error: failure.message,
        );
      },
      (data) {
        final raw = data['data']?['items'] ?? [];

        final list = (raw as List)
            .whereType<Map<String, dynamic>>()
            .map(AOSAdListItem.fromJson)
            .toList();

        final merged = _offset == 0 ? list : [...state.items, ...list];

        _offset += list.length;

        state = state.copyWith(
          items: merged,
          hasMore: list.length == _limit,
          loading: false,
          loadingMore: false,
        );
      },
    );
  }

  Future<void> refresh() async {
    _offset = 0;

    state = state.copyWith(hasMore: true, items: [], error: null);

    await load(initial: true);
  }

  void toggleView() {
    state = state.copyWith(
      view: state.view == ViewMode.grid ? ViewMode.list : ViewMode.grid,
    );
  }

  void setCategory(String? id) {
    if (isWishlist) return;

    _offset = 0;

    state = state.copyWith(selectedCategoryId: id, items: [], hasMore: true);

    load(initial: true);
  }

  void setDealType(DealType type) {
    if (isWishlist) return;

    _offset = 0;

    state = state.copyWith(selectedDealType: type, items: [], hasMore: true);

    load(initial: true);
  }
}
