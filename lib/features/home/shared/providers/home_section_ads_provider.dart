import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';
import 'package:africaonlinestores/features/home/domain/market_place.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';
import 'package:africaonlinestores/features/home/shared/utils/category_lookup.dart';

/// Request for a Home ads section.
///
/// This is separated from [HomeAdsSection] so we can include dynamic params
/// (e.g., resolved categoryId) if we need them later.

class HomeSectionAdsRequest {
  const HomeSectionAdsRequest({required this.section, required this.market});

  final HomeAdsSection section;
  final MarketContext market;

  @override
  bool operator ==(Object other) {
    return other is HomeSectionAdsRequest &&
        other.section.key == section.key &&
        other.market == market;
  }

  @override
  int get hashCode => Object.hash(section.key, market);
}

final homeSectionAdsProvider = FutureProvider.autoDispose
    .family<List<AOSAdListItem>, HomeSectionAdsRequest>((ref, req) async {
      final market = req.market;

      if (market.country.trim().isEmpty) {
        return const <AOSAdListItem>[];
      }

      String? categoryId;
      if (req.section.preferredCategoryNames.isNotEmpty) {
        final catsState = ref.watch(categoriesControllerProvider);
        categoryId = findCategoryIdByNames(
          catsState.parents,
          req.section.preferredCategoryNames,
        );
      }

      final res = await ref
          .read(adsApiProvider)
          .listAds(
            countryName: market.country,
            locationId: market.locationId,
            categoryId: categoryId,
            sort: req.section.sort,
            limit: req.section.limit,
            offset: 0,
          );

      return res.fold((_) => const <AOSAdListItem>[], (payload) {
        final data = payload['data'];
        final rawItems = (data is Map) ? data['items'] : null;
        if (rawItems is! List) return const <AOSAdListItem>[];
        return rawItems
            .whereType<Map>()
            .map((e) => AOSAdListItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
    });
