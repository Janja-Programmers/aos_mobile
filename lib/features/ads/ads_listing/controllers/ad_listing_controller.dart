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

  /// prevents older tab responses from overwriting newer ones
  int _requestId = 0;

  /// -------------------------
  /// INIT
  /// -------------------------
  Future<void> init() async {
    state = state.copyWith(
      loading: true,
      error: null,
      selectedTab: AdTab.active,
    );

    await Future.wait([_loadCounts(), load(AdTab.active, showLoader: true)]);
  }

  /// -------------------------
  /// LOAD LISTINGS
  /// -------------------------
  Future<void> load(AdTab tab, {bool showLoader = true}) async {
    final currentRequest = ++_requestId;

    state = state.copyWith(
      selectedTab: tab,
      error: null,
      loading: showLoader && state.items.isEmpty,
    );

    final api = ref.read(adsApiProvider);

    if (tab == AdTab.drafts) {
      final res = await api.listAdDrafts();

      if (currentRequest != _requestId) return;

      res.fold(
        (f) {
          state = state.copyWith(
            loading: false,
            error: f.message,
            items: const [],
          );
        },
        (data) {
          final dataMap = (data['data'] ?? {}) as Map;
          final itemsRaw = dataMap['items'];

          final list = <AOSAdListItem>[];

          if (itemsRaw is List) {
            for (final e in itemsRaw) {
              if (e is Map) {
                list.add(AOSAdListItem.fromDraft(Map<String, dynamic>.from(e)));
              }
            }
          }

          state = state.copyWith(loading: false, error: null, items: list);
        },
      );

      return;
    }

    final status = tab.backendStatus;

    if (status == null) {
      if (currentRequest != _requestId) return;

      state = state.copyWith(loading: false, error: null, items: const []);
      return;
    }

    final res = await api.myAds(status: status);

    if (currentRequest != _requestId) return;

    res.fold(
      (f) {
        state = state.copyWith(
          loading: false,
          error: f.message,
          items: const [],
        );
      },
      (data) {
        final dataMap = (data['data'] ?? {}) as Map;
        final itemsRaw = dataMap['items'];

        final list = itemsRaw is List
            ? itemsRaw
                  .map(
                    (e) => AOSAdListItem.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
            : <AOSAdListItem>[];

        state = state.copyWith(loading: false, error: null, items: list);
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

    final draftsRes = await api.listAdDrafts();

    draftsRes.fold((_) => newCounts[AdTab.drafts] = 0, (data) {
      final dataMap = (data['data'] ?? {}) as Map;
      final items = dataMap['items'];
      newCounts[AdTab.drafts] = items is List ? items.length : 0;
    });

    state = state.copyWith(counts: newCounts);
  }

  /// -------------------------
  /// RELOAD CURRENT TAB ONLY
  /// -------------------------
  Future<void> reload() async {
    await load(state.selectedTab, showLoader: false);
  }

  /// -------------------------
  /// REFRESH CURRENT TAB + COUNTS
  /// -------------------------
  Future<void> refreshAll() async {
    await Future.wait([
      load(state.selectedTab, showLoader: false),
      _loadCounts(),
    ]);
  }

  /// -------------------------
  /// CHANGE TAB
  /// -------------------------
  Future<void> changeTab(AdTab tab) async {
    await load(tab, showLoader: false);
  }

  /// -------------------------
  /// MARK AS SOLD / RENEW
  /// -------------------------
  Future<void> markSold(AOSAdListItem ad) async {
    final api = ref.read(adsApiProvider);

    final action = state.selectedTab == AdTab.declined ? 'renew' : 'mark_sold';

    final res = await api.setAdStatus(adId: ad.id, action: action);

    await res.fold(
      (f) async {
        state = state.copyWith(error: f.message);
      },
      (_) async {
        await refreshAll();
      },
    );
  }

  /// -------------------------
  /// ABANDON DRAFT
  /// -------------------------
  Future<void> abandonDraft(AOSAdListItem ad) async {
    final api = ref.read(adsApiProvider);

    final res = await api.abandonAdDraft(draftId: ad.id);

    await res.fold(
      (f) async {
        state = state.copyWith(error: f.message);
      },
      (_) async {
        await refreshAll();
      },
    );
  }
}
