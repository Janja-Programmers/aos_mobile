import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:africaonlinestores/features/account/shared/routing/account_routes.dart';
import 'package:africaonlinestores/features/ads/ads_create/create_ad_flow_screen.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/pickers/select_category_screen.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/auth/shared/routing/auth_routes.dart';
import 'package:africaonlinestores/features/catalog/shared/routing/catalog_routes.dart';
import 'package:africaonlinestores/features/onboarding/onboarding_screen.dart';

import 'package:africaonlinestores/core/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/core/routing/app_shell.dart';
import 'package:africaonlinestores/core/routing/app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final authStream = ref.watch(authControllerProvider.notifier).stream;
  final bootstrapAsync = ref.watch(appBootstrapProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: GoRouterRefreshStream(authStream),
    routes: [
      // 🔓 Public auth routes
      ...AuthRoutes.routes(),

      // 🧭 Onboarding
      GoRoute(
        name: AppRoutes.nOnboarding,
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 🚀 CREATE AD (OUTSIDE SHELL)
      GoRoute(
        name: AppRoutes.nCreateAd,
        path: AppRoutes.createAd,
        builder: (context, state) {
          final adId = state.uri.queryParameters['adId'];
          final draftId = state.uri.queryParameters['draftId'];

          return CreateAdFlowScreen(adId: adId, draftId: draftId);
        },
      ),

      // Picker Routes
      GoRoute(
        name: AppRoutes.nSelectCategory,
        path: AppRoutes.selectCategory,
        builder: (context, state) => SelectCategoryScreen(
          parent: state.extra is CategoryNode
              ? state.extra as CategoryNode
              : null,
        ),
      ),

      GoRoute(
        name: AppRoutes.nSelectLocation,
        path: AppRoutes.selectLocation,
        builder: (_, _) => const SelectLocationScreen(),
      ),

      // 🏠 Main app shell (bottom navigation)
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
      final bootstrap = bootstrapAsync.value;
      if (bootstrap == null || !bootstrap.isReady) {
        return null;
      }

      final completed = bootstrap.onboardingCompleted;
      final loc = state.matchedLocation;

      final isOnboarding = loc == AppRoutes.onboarding;
      final isAuthRoute = loc.startsWith('/auth');
      final isAccountRoute = loc.startsWith('/account');
      final isSellerRoute = loc.startsWith('/seller');

      // 🚨 Force onboarding if not completed
      if (!completed && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      // ✅ Prevent returning to onboarding after completion
      if (completed && isOnboarding) {
        return AppRoutes.home;
      }

      // 🔐 Protect account & seller routes
      if (!auth.isLoggedIn && (isAccountRoute || isSellerRoute)) {
        return AppRoutes.login;
      }

      // 🔁 Logged-in users shouldn’t see auth pages
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
