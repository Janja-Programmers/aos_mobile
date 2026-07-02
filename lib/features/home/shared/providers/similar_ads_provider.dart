import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final similarAdsProvider = FutureProvider.family<List<AOSAdListItem>, String>((
  ref,
  categoryId,
) async {
  final res = await ref
      .read(adsApiProvider)
      .listAds(categoryId: categoryId, limit: 8);

  return res.fold((_) => const [], (payload) {
    final data = asJsonMap(payload['data']);
    final raw = data['items'];

    return asJsonMapList(
      raw,
    ).map(AOSAdListItem.fromJson).toList(growable: false);
  });
});
