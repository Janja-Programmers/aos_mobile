import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_controller.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_state.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_params.dart';

final allAdsControllerProvider = StateNotifierProvider.autoDispose
    .family<AllAdsController, AllAdsState, AllAdsParams>(
      (ref, params) => AllAdsController(ref, params),
    );
