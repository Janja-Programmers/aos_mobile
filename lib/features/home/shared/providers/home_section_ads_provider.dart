import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';
import 'package:africaonlinestores/features/home/domain/market_place.dart';
import 'package:africaonlinestores/features/home/shared/utils/category_lookup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
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
        final catsState = ref.read(categoriesControllerProvider);

        categoryId = findParentCategoryIdByNames(
          catsState.parents,
          req.section.preferredCategoryNames,
        );

        if (categoryId == null || categoryId.trim().isEmpty) {
          return const <AOSAdListItem>[];
        }
      }

      final res = await ref
          .read(adsApiProvider)
          .listAds(
            locationId: market.locationId,
            categoryId: categoryId,
            sort: req.section.sort,
            promotionType: req.section.promotionType,
            limit: req.section.limit,
          );

      return res.fold((_) => const <AOSAdListItem>[], (payload) {
        final data = asJsonMap(payload['data']);
        return asJsonMapList(
          data['items'],
        ).map(AOSAdListItem.fromJson).toList();
      });
    });
