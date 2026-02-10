import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/catalog/ui/categories_screen.dart';

class CatalogRoutes {
  const CatalogRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
    ];
  }
}
