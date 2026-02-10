import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/ads/ui/create_ad_flow_screen.dart';
import 'package:africaonlinestores/features/ads/ui/my_ads_screen.dart';
import 'package:africaonlinestores/features/ads/ui/pickers/select_category_screen.dart';
import 'package:africaonlinestores/features/ads/ui/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

class AdsRoutes {
  const AdsRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: AppRoutes.createAd,
        builder: (context, state) => const CreateAdFlowScreen(),
      ),
      GoRoute(
        path: AppRoutes.myAds,
        builder: (context, state) => const MyAdsScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectLocation,
        builder: (context, state) => const SelectLocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectCategory,
        builder: (context, state) {
          final parent = state.extra is CategoryNode
              ? state.extra as CategoryNode
              : null;
          return SelectCategoryScreen(parent: parent);
        },
      ),
    ];
  }
}
