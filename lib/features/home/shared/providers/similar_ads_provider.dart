import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

final similarAdsProvider = FutureProvider.family<List<AOSAdListItem>, String>((
  ref,
  categoryId,
) async {
  final res = await ref
      .read(adsApiProvider)
      .listAds(categoryId: categoryId, limit: 8, offset: 0);

  return res.fold((_) => const [], (payload) {
    final raw = payload['data']?['items'];
    if (raw is! List) return const [];

    return raw
        .map((e) => AOSAdListItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  });
});
