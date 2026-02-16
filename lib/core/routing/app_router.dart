import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/features/account/routing/account_routes.dart';
import 'package:africaonlinestores/features/ads/routing/ads_routes.dart';
import 'package:africaonlinestores/features/auth/routing/auth_routes.dart';
import 'package:africaonlinestores/features/catalog/routing/catalog_routes.dart';

import 'package:africaonlinestores/core/routing/app_shell.dart';
import 'package:africaonlinestores/core/routing/app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final authStream = ref.watch(authControllerProvider.notifier).stream;

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: GoRouterRefreshStream(authStream),

    routes: [
      // Public auth routes
      ...AuthRoutes.routes(),

      // Main app shell (bottom nav)
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          ...AdsRoutes.routes(),
          ...CatalogRoutes.routes(),
          ...AccountRoutes.routes(),
        ],
      ),
    ],

    redirect: (context, state) {
      final loc = state.matchedLocation;

      final isAuthRoute = loc.startsWith('/auth');
      final isAccountRoute = loc.startsWith('/account');
      final isSellerRoute = loc.startsWith('/seller');

      if (!auth.isLoggedIn && (isAccountRoute || isSellerRoute)) {
        return AppRoutes.login;
      }

      if (auth.isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
