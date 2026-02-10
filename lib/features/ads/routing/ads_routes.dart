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
        name: AppRoutes.nMyAds,
        path: AppRoutes.myAds,
        builder: (context, state) => const MyAdsScreen(),
      ),
      GoRoute(
        name: AppRoutes.nCreateAd,
        path: AppRoutes.createAd,
        builder: (context, state) => const CreateAdFlowScreen(),
      ),
      GoRoute(
        name: AppRoutes.nSelectCategory,
        path: AppRoutes.selectCategory,
        builder: (context, state) {
          final parent = state.extra is CategoryNode
              ? state.extra as CategoryNode
              : null;
          return SelectCategoryScreen(parent: parent);
        },
      ),
      GoRoute(
        name: AppRoutes.nSelectLocation,
        path: AppRoutes.selectLocation,
        builder: (context, state) => const SelectLocationScreen(),
      ),
    ];
  }
}
