import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';

class HomePageState {
  const HomePageState({
    required this.sections,
    required this.sectionItems,
    required this.discoverItems,
    required this.initialLoading,
    required this.loadingMore,
    required this.hasMore,
  });

  final List<HomeAdsSection> sections;
  final Map<String, List<AOSAdListItem>> sectionItems;
  final List<AOSAdListItem> discoverItems;

  final bool initialLoading;
  final bool loadingMore;
  final bool hasMore;

  HomePageState copyWith({
    Map<String, List<AOSAdListItem>>? sectionItems,
    List<AOSAdListItem>? discoverItems,
    bool? initialLoading,
    bool? loadingMore,
    bool? hasMore,
  }) {
    return HomePageState(
      sections: sections,
      sectionItems: sectionItems ?? this.sectionItems,
      discoverItems: discoverItems ?? this.discoverItems,
      initialLoading: initialLoading ?? this.initialLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory HomePageState.initial(List<HomeAdsSection> sections) {
    return HomePageState(
      sections: sections,
      sectionItems: {},
      discoverItems: const [],
      initialLoading: true,
      loadingMore: false,
      hasMore: true,
    );
  }
}
