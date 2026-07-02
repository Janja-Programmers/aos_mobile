import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/ads_listing/controllers/ad_listing_state.dart';
import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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

  /// prevents older count responses from overwriting newer ones
  int _countsRequestId = 0;

  /// -------------------------
  /// INIT
  /// -------------------------
  Future<void> init() async {
    state = state.copyWith(loading: true, selectedTab: AdTab.active);

    await Future.wait([_loadCounts(), load(AdTab.active)]);
  }

  /// -------------------------
  /// LOAD LISTINGS
  /// -------------------------
  Future<void> load(AdTab tab, {bool showLoader = true}) async {
    final currentRequest = ++_requestId;

    state = state.copyWith(
      selectedTab: tab,
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
          final dataMap = asJsonMap(data['data']);
          final itemsRaw = dataMap['items'];

          final list = <AOSAdListItem>[];

          for (final e in asJsonMapList(itemsRaw)) {
            list.add(AOSAdListItem.fromDraft(e));
          }

          state = state.copyWith(loading: false, items: list);
        },
      );

      return;
    }

    final status = tab.backendStatus;

    if (status == null) {
      if (currentRequest != _requestId) return;

      state = state.copyWith(loading: false, items: const []);
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
        final dataMap = asJsonMap(data['data']);
        final itemsRaw = dataMap['items'];

        final list = asJsonMapList(
          itemsRaw,
        ).map(AOSAdListItem.fromJson).toList(growable: false);

        state = state.copyWith(loading: false, items: list);
      },
    );
  }

  /// -------------------------
  /// LOAD COUNTS
  /// -------------------------
  Future<void> _loadCounts() async {
    final currentCountsRequest = ++_countsRequestId;
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

      // A newer counts request has started. Ignore this old one.
      if (currentCountsRequest != _countsRequestId) return;

      res.fold((_) => newCounts[tab] = 0, (data) {
        final dataMap = asJsonMap(data['data']);
        final pagination = asJsonMap(dataMap['pagination']);

        final totalRaw = pagination['total'];
        final total = totalRaw is int
            ? totalRaw
            : int.tryParse('$totalRaw') ?? 0;

        newCounts[tab] = total;
      });
    }

    final draftsRes = await api.listAdDrafts();

    // A newer counts request has started. Ignore this old one.
    if (currentCountsRequest != _countsRequestId) return;

    draftsRes.fold((_) => newCounts[AdTab.drafts] = 0, (data) {
      final dataMap = asJsonMap(data['data']);
      final items = dataMap['items'];
      newCounts[AdTab.drafts] = items is List ? items.length : 0;
    });

    // Final guard before committing counts.
    if (currentCountsRequest != _countsRequestId) return;

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
    final tab = state.selectedTab;

    await load(tab, showLoader: false);
    await _loadCounts();
  }

  /// -------------------------
  /// CHANGE TAB
  /// -------------------------
  Future<void> changeTab(AdTab tab) async {
    await load(tab, showLoader: false);
  }

  Future<void> _runStatusAction({
    required AOSAdListItem ad,
    required String action,
  }) async {
    final api = ref.read(adsApiProvider);

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
  /// MARK AS SOLD
  /// -------------------------
  Future<void> markSold(AOSAdListItem ad) async {
    await _runStatusAction(ad: ad, action: 'mark_sold');
  }

  /// -------------------------
  /// MARK SOLD AD AS AVAILABLE
  /// -------------------------
  Future<void> markAvailable(AOSAdListItem ad) async {
    await _runStatusAction(ad: ad, action: 'mark_available');
  }

  /// -------------------------
  /// RENEW EXPIRED AD
  /// -------------------------
  Future<void> renew(AOSAdListItem ad) async {
    await _runStatusAction(ad: ad, action: 'renew');
  }

  /// -------------------------
  /// DELETE LISTING / ABANDON DRAFT
  /// -------------------------
  Future<void> deleteListing(AOSAdListItem ad) async {
    if (state.selectedTab != AdTab.drafts) {
      await _runStatusAction(ad: ad, action: 'delete');
      return;
    }

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
