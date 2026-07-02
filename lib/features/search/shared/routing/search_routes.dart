import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchRoutes {
  const SearchRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nSearch,
        path: AppRoutes.search,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'text';

          return SearchScreen(initialMode: mode);
        },
      ),
    ];
  }
}

class SearchNavigation {
  const SearchNavigation._();

  static void toSearchscreen(BuildContext context, {String mode = 'text'}) {
    context.pushNamed(AppRoutes.nSearch, queryParameters: {'mode': mode});
  }

  static void toTextSearch(BuildContext context) {
    toSearchscreen(context);
  }

  static void toVoiceSearch(BuildContext context) {
    toSearchscreen(context, mode: 'voice');
  }

  static void toImageSearch(BuildContext context) {
    toSearchscreen(context, mode: 'image');
  }
}
