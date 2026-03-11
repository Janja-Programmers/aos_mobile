import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/catalog/data/categories_api.dart';

final categoriesApiProvider = Provider<CategoriesApi>((ref) {
  return CategoriesApi(ref.watch(apiClientProvider));
});

final forYouAdsProvider = FutureProvider.family<List<AOSAdListItem>, String>((
  ref,
  categoryId,
) async {
  // 🔥 Resolve market explicitly
  // final market = await ref.read(marketContextProvider.future);

  final adsApi = ref.read(adsApiProvider);

  final res = await adsApi.listAds(
    locationId: "",
    categoryId: categoryId,
    limit: 10,
    offset: 0,
  );

  if (res.isLeft) return [];

  final payload = res.rightOrNull ?? {};
  final rawItems = payload['data']?['items'];

  if (rawItems is! List) return [];

  return rawItems
      .whereType<Map<String, dynamic>>()
      .map((e) => AOSAdListItem.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});
