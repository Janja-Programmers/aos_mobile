import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forYouAdsProvider = FutureProvider.family<List<AOSAdListItem>, String>((
  ref,
  categoryId,
) async {
  final adsApi = ref.read(adsApiProvider);
  final country = 'Kenya';

  final res = await adsApi.listAds(
    countryName: country,
    categoryId: categoryId,
    limit: 10,
  );

  if (res.isLeft) return [];

  final payload = res.rightOrNull ?? {};
  final data = payload['data'];

  if (data is! List) return [];

  return data
      .map((e) => AOSAdListItem.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});
