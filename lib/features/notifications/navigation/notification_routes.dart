import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/notifications/presentation/screens/notification_screen.dart';

class NotificationsRoutes {
  const NotificationsRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nNavigation,
        path: AppRoutes.navigation,
        builder: (context, state) {
          return const NotificationsScreen();
        },
      ),
    ];
  }
}

class NotificationsNavigation {
  const NotificationsNavigation._();

  static void toNavigations(BuildContext context) {
    context.pushNamed(AppRoutes.nNavigation);
  }
}
