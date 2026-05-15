import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';

class AdListingsState {
  final bool loading;
  final String? error;
  final List<AOSAdListItem> items;

  final AdTab selectedTab;
  final Map<AdTab, int> counts;

  const AdListingsState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.selectedTab = AdTab.active,
    this.counts = const {},
  });

  /// All tabs (single source of truth)
  List<AdTab> get tabs => const [
    AdTab.active,
    AdTab.drafts,
    AdTab.reviewing,
    AdTab.declined,
    AdTab.sold,
    AdTab.expired,
    AdTab.suspended,
  ];

  AdListingsState copyWith({
    bool? loading,
    String? error,
    List<AOSAdListItem>? items,
    AdTab? selectedTab,
    Map<AdTab, int>? counts,
  }) {
    return AdListingsState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      selectedTab: selectedTab ?? this.selectedTab,
      counts: counts ?? this.counts,
    );
  }
}
