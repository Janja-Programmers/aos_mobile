import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myAdsProvider = FutureProvider.autoDispose<List<AOSAdListItem>>((
  ref,
) async {
  final api = ref.read(adsApiProvider);

  final result = await api.myAds();

  return result.fold((failure) => throw failure, (json) {
    final data = asJsonMap(json['data']);
    final items = asJsonMapList(data['items']);

    return items.map(AOSAdListItem.fromJson).toList();
  });
});
