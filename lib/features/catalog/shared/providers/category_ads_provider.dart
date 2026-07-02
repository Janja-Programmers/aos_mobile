import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/catalog/data/categories_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    locationId: '',
    categoryId: categoryId,
    limit: 10,
  );

  if (res.isLeft) return [];

  final payload = asJsonMap(res.rightOrNull);
  final data = asJsonMap(payload['data']);
  final rawItems = asJsonMapList(data['items']);

  return rawItems.map(AOSAdListItem.fromJson).toList();
});
