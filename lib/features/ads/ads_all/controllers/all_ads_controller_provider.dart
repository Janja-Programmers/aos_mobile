import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_controller.dart';
import 'package:africaonlinestores/features/ads/ads_all/controllers/all_ads_state.dart';

final allAdsControllerProvider =
    StateNotifierProvider.autoDispose<AllAdsController, AllAdsState>(
      (ref) => AllAdsController(ref),
    );
