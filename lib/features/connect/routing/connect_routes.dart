import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/connect/converaation/presentation/connect_screen.dart';

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

  static void toCallsTab(BuildContext context) {
    context.pushNamed(AppRoutes.nConnect, queryParameters: {'tab': 'calls'});
  }

  static void toMessagesTab(BuildContext context) {
    context.pushNamed(AppRoutes.nConnect, queryParameters: {'tab': 'messages'});
  }
}
