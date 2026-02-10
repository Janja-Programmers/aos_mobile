import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/home/ui/ad_details_screen.dart';
import 'package:africaonlinestores/features/home/ui/ad_list_screen.dart';

class HomeRoutes {
  const HomeRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const AdListScreen(),
      ),
      GoRoute(
        path: AppRoutes.adDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AdDetailsScreen(id: id);
        },
      ),
    ];
  }
}
