import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/ads/ads_listing/controllers/ad_listing_state.dart';
import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

final adListingControllerProvider =
    StateNotifierProvider<AdListingsController, AdListingsState>((ref) {
      return AdListingsController(ref);
    });

class AdListingsController extends StateNotifier<AdListingsState> {
  AdListingsController(this.ref) : super(const AdListingsState()) {
    init();
  }

  final Ref ref;

  /// -------------------------
  /// INIT
  /// -------------------------
  Future<void> init() async {
    await _loadCounts();
    await load(AdTab.active);
  }

  /// -------------------------
  /// LOAD LISTINGS
  /// -------------------------
  Future<void> load(AdTab tab) async {
    state = state.copyWith(loading: true, error: null, selectedTab: tab);

    final api = ref.read(adsApiProvider);

    /// -------------------------
    /// DRAFTS
    /// -------------------------
    if (tab == AdTab.drafts) {
      final res = await api.listAdDrafts();

      res.fold(
        (f) => state = state.copyWith(
          loading: false,
          error: f.message,
          items: const [],
        ),
        (data) {
          final dataMap = (data['data'] ?? {}) as Map;
          final itemsRaw = dataMap['items'];

          final list = <AOSAdListItem>[];

          if (itemsRaw is List) {
            for (final e in itemsRaw) {
              if (e is Map) {
                final map = Map<String, dynamic>.from(e);
                list.add(AOSAdListItem.fromDraft(map));
              }
            }
          }

          state = state.copyWith(loading: false, items: list);
        },
      );

      return;
    }

    /// -------------------------
    /// NORMAL ADS
    /// -------------------------
    final status = tab.backendStatus;

    if (status == null) {
      // defensive guard (should never happen)
      state = state.copyWith(loading: false, items: const []);
      return;
    }

    final res = await api.myAds(status: status);

    res.fold(
      (f) => state = state.copyWith(
        loading: false,
        error: f.message,
        items: const [],
      ),
      (data) {
        final items = (data['data']['items'] as List)
            .map((e) => AOSAdListItem.fromJson(e))
            .toList();

        state = state.copyWith(loading: false, items: items);
      },
    );
  }

  /// -------------------------
  /// LOAD COUNTS
  /// -------------------------
  Future<void> _loadCounts() async {
    final api = ref.read(adsApiProvider);

    final Map<AdTab, int> newCounts = {};

    final tabs = [
      AdTab.active,
      AdTab.reviewing,
      AdTab.declined,
      AdTab.sold,
      AdTab.expired,
      AdTab.suspended,
    ];

    for (final tab in tabs) {
      final status = tab.backendStatus;

      if (status == null) {
        newCounts[tab] = 0;
        continue;
      }

      final res = await api.myAds(status: status);

      res.fold((_) => newCounts[tab] = 0, (data) {
        final dataMap = (data['data'] ?? {}) as Map;
        final pagination = (dataMap['pagination'] ?? {}) as Map;

        final totalRaw = pagination['total'];
        final total = totalRaw is int
            ? totalRaw
            : int.tryParse('$totalRaw') ?? 0;

        newCounts[tab] = total;
      });
    }

    /// -------------------------
    /// DRAFTS (separate API)
    /// -------------------------
    final draftsRes = await api.listAdDrafts();

    draftsRes.fold((_) => newCounts[AdTab.drafts] = 0, (data) {
      final dataMap = (data['data'] ?? {}) as Map;
      final items = dataMap['items'];

      newCounts[AdTab.drafts] = items is List ? items.length : 0;
    });

    state = state.copyWith(counts: newCounts);
  }

  /// -------------------------
  /// RELOAD
  /// -------------------------
  Future<void> reload() async {
    await load(state.selectedTab);
  }

  /// -------------------------
  /// CHANGE TAB
  /// -------------------------
  Future<void> changeTab(AdTab tab) async {
    await load(tab);
  }

  /// -------------------------
  /// EDIT AD
  /// -------------------------
  void editAd(AOSAdListItem ad) {
    // navigation handled in UI
  }

  /// -------------------------
  /// MARK AS SOLD / RENEW
  /// -------------------------
  Future<void> markSold(AOSAdListItem ad) async {
    final api = ref.read(adsApiProvider);

    final action = state.selectedTab == AdTab.declined ? 'renew' : 'mark_sold';

    final res = await api.setAdStatus(adId: ad.id, action: action);

    res.fold(
      (f) {
        state = state.copyWith(error: f.message);
      },
      (_) {
        reload();
      },
    );
  }

  /// -------------------------
  /// ABANDON DRAFT
  /// -------------------------
  Future<void> abandonDraft(AOSAdListItem ad) async {
    final api = ref.read(adsApiProvider);

    /// Defensive: ensure it's a draft
    final isDraft = ad.id.startsWith('DRAFT');

    if (!isDraft) {
      state = state.copyWith(error: 'Invalid draft item.');
      return;
    }

    final res = await api.abandonAdDraft(draftId: ad.id);

    await res.fold(
      (f) {
        state = state.copyWith(error: f.message);
      },
      (_) async {
        /// Reload current tab (Drafts)
        await reload();
      },
    );
  }
}
