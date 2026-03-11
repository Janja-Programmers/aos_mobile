import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

final adDetailsControllerProvider = FutureProvider.family<AOSAdDetails, String>(
  (ref, adId) async {
    final res = await ref.read(adsApiProvider).getAd(adId: adId);

    return res.fold((f) => throw Exception(f.message), (json) {
      final data = json['data'];
      final adJson = (data is Map) ? (data['item'] ?? data) : null;

      if (adJson is! Map) {
        throw Exception("Failed to load ad");
      }

      return AOSAdDetails.fromJson(Map<String, dynamic>.from(adJson));
    });
  },
);
