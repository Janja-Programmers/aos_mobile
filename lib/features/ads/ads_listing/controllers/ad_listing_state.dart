import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

class AdListingsState {
  final bool loading;
  final String? error;
  final List<AOSAdListItem> items;

  final String selectedTab;
  final Map<String, int> counts;

  const AdListingsState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.selectedTab = 'Active',
    this.counts = const {},
  });

  List<String> get tabs => const ['Active', 'Reviewing', 'Drafts', 'Declined'];

  AdListingsState copyWith({
    bool? loading,
    String? error,
    List<AOSAdListItem>? items,
    String? selectedTab,
    Map<String, int>? counts,
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
