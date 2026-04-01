import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';

import 'package:africaonlinestores/features/search/search_screen.dart';

class SearchRoutes {
  const SearchRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nSearch,
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
    ];
  }
}

class SearchNavigation {
  const SearchNavigation._();

  static void toSearchscreen(BuildContext context) {
    context.pushNamed(AppRoutes.nSearch);
  }
}
