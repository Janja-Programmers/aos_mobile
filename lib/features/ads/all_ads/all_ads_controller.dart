import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/all_ads/all_ads_state.dart';

class AllAdsArgs {
  final String parentId;
  final String? initialId;

  const AllAdsArgs(this.parentId, this.initialId);
}

final allAdsControllerProvider = StateNotifierProvider.autoDispose
    .family<AllAdsController, AllAdsState, AllAdsArgs>(
      (ref, args) => AllAdsController(ref, args),
    );

class AllAdsController extends StateNotifier<AllAdsState> {
  AllAdsController(this.ref, this.args)
    : super(AllAdsState(selectedCategoryId: args.initialId)) {
    load(initial: true);
  }

  final Ref ref;
  final AllAdsArgs args;

  int _offset = 0;
  static const _limit = 20;

  // ================= Fetch =================

  Future<void> load({bool initial = false}) async {
    if (state.loading || state.loadingMore) return;
    if (!state.hasMore && !initial) return;

    state = state.copyWith(loading: initial, loadingMore: !initial);

    final api = ref.read(adsApiProvider);

    final res = await api.listAds(
      countryName: 'Kenya',
      categoryId: state.selectedCategoryId ?? args.parentId,
      limit: _limit,
      offset: _offset,
    );

    res.fold((f) => state = state.copyWith(error: f.message), (data) {
      final raw = data['data']?['items'] ?? [];

      final list = raw
          .whereType<Map<String, dynamic>>()
          .map(AOSAdListItem.fromJson)
          .toList();

      final merged = _offset == 0 ? list : [...state.items, ...list];

      _offset += list.length as int;

      state = state.copyWith(items: merged, hasMore: list.length == _limit);
    });

    state = state.copyWith(loading: false, loadingMore: false);
  }

  // ================= Actions =================

  Future<void> refresh() async {
    _offset = 0;
    state = state.copyWith(hasMore: true, items: []);
    await load(initial: true);
  }

  void toggleView() {
    state = state.copyWith(
      view: state.view == ViewMode.grid ? ViewMode.list : ViewMode.grid,
    );
  }

  void setCategory(String? id) {
    state = state.copyWith(selectedCategoryId: id);
    refresh();
  }
}
