import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';
import 'package:africaonlinestores/features/home/domain/market_place.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_controller.dart';
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

@Deprecated('Read homePageControllerProvider instead.')
final homeSectionAdsProvider = FutureProvider.autoDispose
    .family<List<AOSAdListItem>, HomeSectionAdsRequest>((ref, request) async {
      if (request.market.country.trim().isEmpty) {
        return const <AOSAdListItem>[];
      }

      final page = await ref.watch(homePageControllerProvider.future);
      if (page.locationId != request.market.locationId) {
        return const <AOSAdListItem>[];
      }

      return page.sectionItems[request.section.key] ?? const <AOSAdListItem>[];
    });
