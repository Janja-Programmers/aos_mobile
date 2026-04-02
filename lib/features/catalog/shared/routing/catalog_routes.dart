import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/catalog/presentation/categories_screen.dart';

class CatalogRoutes {
  const CatalogRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nCategories,
        path: AppRoutes.categories,
        builder: (context, state) {
          final ctx = (state.extra as NavContext?) ?? NavContext.root;

          return CategoriesScreen(navContext: ctx);
        },
      ),
    ];
  }
}

class CatalogNavigation {
  const CatalogNavigation._();

  static void toAllCategories(BuildContext context) {
    context.pushNamed(AppRoutes.nCategories, extra: NavContext.pushed);
  }
}
