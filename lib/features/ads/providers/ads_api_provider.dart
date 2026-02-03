import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';

final adsApiProvider = Provider<AdsApi>((ref) {
  return AdsApi(ref.read(apiClientProvider));
});
