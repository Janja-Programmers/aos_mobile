import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adsApiProvider = Provider<AdsApi>((ref) {
  return AdsApi(ref.read(apiClientProvider));
});
