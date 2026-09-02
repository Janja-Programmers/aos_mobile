import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

const Object _unsetHomeLocation = Object();

class HomePageState {
  const HomePageState({
    this.locationId,
    required this.sections,
    required this.selectedCategories,
    required this.sectionItems,
    required this.discoverItems,
    required this.shortsForYou,
    required this.initialLoading,
    required this.loadingMore,
    required this.hasMore,
  });

  final String? locationId;
  final List<HomeAdsSection> sections;
  final List<CategoryNode> selectedCategories;
  final Map<String, List<AOSAdListItem>> sectionItems;
  final List<AOSAdListItem> discoverItems;
  final List<Short> shortsForYou;

  final bool initialLoading;
  final bool loadingMore;
  final bool hasMore;

  HomePageState copyWith({
    Object? locationId = _unsetHomeLocation,
    List<HomeAdsSection>? sections,
    List<CategoryNode>? selectedCategories,
    Map<String, List<AOSAdListItem>>? sectionItems,
    List<AOSAdListItem>? discoverItems,
    List<Short>? shortsForYou,
    bool? initialLoading,
    bool? loadingMore,
    bool? hasMore,
  }) {
    return HomePageState(
      locationId: identical(locationId, _unsetHomeLocation)
          ? this.locationId
          : locationId as String?,
      sections: sections ?? this.sections,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      sectionItems: sectionItems ?? this.sectionItems,
      discoverItems: discoverItems ?? this.discoverItems,
      shortsForYou: shortsForYou ?? this.shortsForYou,
      initialLoading: initialLoading ?? this.initialLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory HomePageState.initial(
    List<HomeAdsSection> sections, {
    String? locationId,
    List<CategoryNode> selectedCategories = const <CategoryNode>[],
  }) {
    return HomePageState(
      locationId: locationId,
      sections: sections,
      selectedCategories: selectedCategories,
      sectionItems: const <String, List<AOSAdListItem>>{},
      discoverItems: const <AOSAdListItem>[],
      shortsForYou: const <Short>[],
      initialLoading: true,
      loadingMore: false,
      hasMore: true,
    );
  }
}
