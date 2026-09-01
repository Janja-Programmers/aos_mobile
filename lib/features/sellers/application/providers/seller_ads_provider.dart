import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_controller.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_params.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_state.dart';
import 'package:flutter_riverpod/legacy.dart';

AllAdsParams sellerAdsParams(String sellerId) {
  return AllAdsParams(sellerId: sellerId.trim());
}

/// Seller storefront product discovery reuses the existing AllAdsController.
/// This provider only supplies the fixed seller scope; it owns no alternate
/// repository, serialization, pagination, sort, or filter behavior.
final sellerAdsProvider = StateNotifierProvider.autoDispose
    .family<AllAdsController, AllAdsState, String>((ref, sellerId) {
      return AllAdsController(ref, sellerAdsParams(sellerId));
    });
