import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/ads/ads_listing/controllers/ad_listing_state.dart';
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

  Future<void> init() async {
    await _loadCounts();
    await load('Active');
  }

  Future<void> load(String tab) async {
    state = state.copyWith(loading: true, error: null, selectedTab: tab);

    final api = ref.read(adsApiProvider);

    /// -------------------------
    /// DRAFTS
    /// -------------------------
    if (tab == 'Drafts') {
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

                final ad = AOSAdListItem.fromDraft(map);

                list.add(ad);
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
    final res = await api.myAds(status: tab);

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

  Future<void> _loadCounts() async {
    final api = ref.read(adsApiProvider);

    final Map<String, int> newCounts = {};

    final statuses = {
      'Active': 'Active',
      'Reviewing': 'Reviewing',
      'Declined': 'Declined',
    };

    for (final entry in statuses.entries) {
      final res = await api.myAds(status: entry.value);

      res.fold((_) => newCounts[entry.key] = 0, (data) {
        final dataMap = (data['data'] ?? {}) as Map;
        final pagination = (dataMap['pagination'] ?? {}) as Map;

        final totalRaw = pagination['total'];
        final total = totalRaw is int
            ? totalRaw
            : int.tryParse('$totalRaw') ?? 0;

        newCounts[entry.key] = total;
      });
    }

    /// Drafts
    final draftsRes = await api.listAdDrafts();
    draftsRes.fold((f) {}, (data) {});

    draftsRes.fold((_) => newCounts['Drafts'] = 0, (data) {
      final dataMap = (data['data'] ?? {}) as Map;
      final items = dataMap['items'];

      newCounts['Drafts'] = items is List ? items.length : 0;
    });

    state = state.copyWith(counts: newCounts);
  }

  Future<void> reload() async {
    await load(state.selectedTab);
  }

  Future<void> changeTab(String tab) async {
    await load(tab);
  }

  /// EDIT AD
  void editAd(AOSAdListItem ad) {
    // navigation handled in UI
  }

  /// MARK AS SOLD
  Future<void> markSold(AOSAdListItem ad) async {
    final api = ref.read(adsApiProvider);

    final action = state.selectedTab == 'Declined' ? 'renew' : 'mark_sold';

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
}
