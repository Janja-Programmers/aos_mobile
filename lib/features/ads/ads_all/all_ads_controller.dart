import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/localization/locale_controller.dart';
import 'package:africaonlinestores/core/localization/utils.dart';

import 'package:africaonlinestores/features/localization/domain/locale_bundle.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/ads_all/all_ads_state.dart';
import 'package:flutter_riverpod/legacy.dart';

/// ================= Args =================

class AllAdsArgs {
  final String parentId;
  final String? initialId;

  const AllAdsArgs(this.parentId, this.initialId);
}

/// ================= Provider =================

final allAdsControllerProvider = StateNotifierProvider.autoDispose
    .family<AllAdsController, AllAdsState, AllAdsArgs>(
      (ref, args) => AllAdsController(ref, args),
    );

/// ================= Controller =================

class AllAdsController extends StateNotifier<AllAdsState> {
  AllAdsController(this.ref, this.args)
    : super(AllAdsState(selectedCategoryId: args.initialId)) {
    _bundleFuture = ref.read(localeBundleProvider.future);
    _resolveCountryName();
    load(initial: true);
  }

  final Ref ref;
  final AllAdsArgs args;

  static const _limit = 20;
  int _offset = 0;

  late final Future<LocaleBundle> _bundleFuture;

  String? _countryName;

  // ================= Locale Resolution =================

  Future<void> _resolveCountryName() async {
    final localeAsync = ref.read(localeControllerProvider);

    final prefs = localeAsync.maybeWhen(data: (v) => v, orElse: () => null);

    if (prefs == null || prefs.countryCode.isEmpty) return;

    try {
      final bundle = await _bundleFuture;

      _countryName = labelFor(bundle.countries, prefs.countryCode);
    } catch (_) {
      _countryName = null;
    }
  }

  // ================= Fetch =================

  Future<void> load({bool initial = false}) async {
    if (state.loading || state.loadingMore) return;
    if (!state.hasMore && !initial) return;

    // Ensure country is resolved first
    if (_countryName == null) {
      await _resolveCountryName();

      if (_countryName == null) {
        state = state.copyWith(error: 'Unable to determine country');
        return;
      }
    }

    state = state.copyWith(loading: initial, loadingMore: !initial);

    final api = ref.read(adsApiProvider);

    final res = await api.listAds(
      countryName: _countryName!,
      categoryId: state.selectedCategoryId ?? args.parentId,
      limit: _limit,
      offset: _offset,
    );

    res.fold(
      (f) {
        state = state.copyWith(error: f.message);
      },
      (data) {
        final raw = data['data']?['items'] ?? [];

        final list = raw
            .whereType<Map<String, dynamic>>()
            .map(AOSAdListItem.fromJson)
            .toList();

        final merged = _offset == 0 ? list : [...state.items, ...list];

        _offset = list.length as int;

        state = state.copyWith(items: merged, hasMore: list.length == _limit);
      },
    );

    state = state.copyWith(loading: false, loadingMore: false);
  }

  // ================= Actions =================

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
    state = state.copyWith(selectedCategoryId: id);
    refresh();
  }
}
