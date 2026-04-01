import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

final sellerAdsProvider = FutureProvider.family<List<AOSAdListItem>, String>((
  ref,
  sellerId,
) async {
  final res = await ref
      .read(adsApiProvider)
      .listAds(sellerId: sellerId, limit: 20, offset: 0);

  return res.fold(
    (failure) {
      print("SELLER ADS ERROR: ${failure.message}");
      return const [];
    },
    (payload) {
      print("SELLER ADS RAW: $payload");

      /// 🔥 FIX: correct path
      final raw = payload['data']?['items'];

      if (raw is! List) {
        print("Invalid items format");
        return const [];
      }

      return raw
          .map((e) => AOSAdListItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    },
  );
});
