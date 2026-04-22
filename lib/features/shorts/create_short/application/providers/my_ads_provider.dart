import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

final myAdsProvider = FutureProvider.autoDispose<List<AOSAdListItem>>((
  ref,
) async {
  final api = ref.read(adsApiProvider);

  final result = await api.myAds();

  return result.fold((failure) => throw failure, (json) {
    final items = json['data']?['items'] as List<dynamic>? ?? [];

    return items
        .map((e) => AOSAdListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  });
});
