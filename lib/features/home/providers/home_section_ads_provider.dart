import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/localization/locale_controller.dart';
import 'package:africaonlinestores/core/localization/utils.dart';
import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/providers/categories_controller.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_section.dart';
import 'package:africaonlinestores/features/home/utils/category_lookup.dart';

/// Request for a Home ads section.
///
/// This is separated from [HomeAdsSection] so we can include dynamic params
/// (e.g., resolved categoryId) if we need them later.
class HomeSectionAdsRequest {
  const HomeSectionAdsRequest({
    required this.section,
  });

  final HomeAdsSection section;

  @override
  bool operator ==(Object other) {
    return other is HomeSectionAdsRequest && other.section.key == section.key;
  }

  @override
  int get hashCode => section.key.hashCode;
}

/// Fetches ads for a given home section.
///
/// - Resolves country name from locale prefs + locale bundle.
/// - If section is category-backed, resolves the category id from the catalog
///   tree using [HomeAdsSection.preferredCategoryNames].
final homeSectionAdsProvider = FutureProvider.autoDispose
    .family<List<AOSAdListItem>, HomeSectionAdsRequest>((ref, req) async {
  final prefs = await ref.watch(localeControllerProvider.future);
  final codeOrLabel = prefs.countryCode.trim();
  if (codeOrLabel.isEmpty) return const <AOSAdListItem>[];

  // Convert country code -> display name expected by backend.
  String countryName = 'Kenya';
  try {
    final bundle = await ref.watch(localeBundleProvider.future);
    countryName = labelFor(bundle.countries, codeOrLabel) ?? countryName;
  } catch (_) {
    // Keep fallback.
  }

  String? categoryId;
  if (req.section.preferredCategoryNames.isNotEmpty) {
    final catsState = ref.watch(categoriesControllerProvider);
    categoryId = findCategoryIdByNames(
      catsState.parents,
      req.section.preferredCategoryNames,
    );
  }

  final res = await ref.read(adsApiProvider).listAds(
        countryName: countryName,
        categoryId: categoryId,
        sort: req.section.sort,
        limit: req.section.limit,
        offset: 0,
      );

  return res.fold(
    (_) => const <AOSAdListItem>[],
    (payload) {
      final data = payload['data'];
      final rawItems = (data is Map) ? data['items'] : null;
      if (rawItems is! List) return const <AOSAdListItem>[];
      return rawItems
          .whereType<Map>()
          .map((e) => AOSAdListItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    },
  );
});
