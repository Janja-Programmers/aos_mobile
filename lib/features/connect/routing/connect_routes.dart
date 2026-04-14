import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/connect/presentation/connect_screen.dart';

class ConnectScreenRoutes {
  const ConnectScreenRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nConnect,
        path: AppRoutes.connect,
        builder: (context, state) {
          return const ConnectScreen();
        },
      ),
    ];
  }
}

class ConnectScreenNavigation {
  const ConnectScreenNavigation._();

  static void toAllCategories(BuildContext context) {
    context.pushNamed(AppRoutes.nConnect);
  }
}
