import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';

class HomePageState {
  const HomePageState({
    this.locationId,
    required this.sections,
    required this.sectionItems,
    required this.discoverItems,
    required this.initialLoading,
    required this.loadingMore,
    required this.hasMore,
  });

  final String? locationId;
  final List<HomeAdsSection> sections;
  final Map<String, List<AOSAdListItem>> sectionItems;
  final List<AOSAdListItem> discoverItems;

  final bool initialLoading;
  final bool loadingMore;
  final bool hasMore;

  HomePageState copyWith({
    String? locationId,
    List<HomeAdsSection>? sections,
    Map<String, List<AOSAdListItem>>? sectionItems,
    List<AOSAdListItem>? discoverItems,
    bool? initialLoading,
    bool? loadingMore,
    bool? hasMore,
  }) {
    return HomePageState(
      locationId: locationId ?? this.locationId,
      sections: sections ?? this.sections,
      sectionItems: sectionItems ?? this.sectionItems,
      discoverItems: discoverItems ?? this.discoverItems,
      initialLoading: initialLoading ?? this.initialLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory HomePageState.initial(
    List<HomeAdsSection> sections, {
    String? locationId,
  }) {
    return HomePageState(
      locationId: locationId,
      sections: sections,
      sectionItems: const {},
      discoverItems: const [],
      initialLoading: true,
      loadingMore: false,
      hasMore: true,
    );
  }
}
