import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/home/ui/ad_details_screen.dart';
import 'package:africaonlinestores/features/home/ui/ad_list_screen.dart';
import 'package:africaonlinestores/features/home/ui/all_ads_screen.dart';

class HomeRoutes {
  const HomeRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nHome,
        path: AppRoutes.home,
        builder: (context, state) => const AdListScreen(),
      ),

      GoRoute(
        name: AppRoutes.nAdList,
        path: AppRoutes.adList,
        builder: (context, state) => const AdListScreen(),
      ),

      // ✅ more specific dynamic route FIRST
      GoRoute(
        name: AppRoutes.nAllAds,
        path: AppRoutes.allAds, // /ads/all/:categoryId
        builder: (context, state) {
          final raw = state.pathParameters['categoryId'] ?? '';
          final categoryId = Uri.decodeComponent(raw);

          final showPills = state.uri.queryParameters['pills'] != '0';
          final initialRaw = state.uri.queryParameters['selected'];
          final banner = state.uri.queryParameters['banner'];

          final initial = (initialRaw ?? '').trim().isEmpty
              ? null
              : Uri.decodeComponent(initialRaw!.trim());

          return AllAdsScreen(
            parentCategoryId: categoryId,
            initialCategoryId: initial,
            showPills: showPills,
            bannerUrl: (banner ?? '').trim().isEmpty ? null : banner,
          );
        },
      ),

      // ✅ MOST generic route LAST
      GoRoute(
        name: AppRoutes.nAdDetails,
        path: AppRoutes.adDetails, // /ads/:id
        builder: (context, state) {
          final raw = state.pathParameters['id'] ?? '';
          final id = Uri.decodeComponent(raw);
          return AdDetailsScreen(id: id);
        },
      ),
    ];
  }
}
