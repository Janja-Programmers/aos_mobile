import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/features/account/routing/account_routes.dart';
import 'package:africaonlinestores/features/ads/routing/ads_routes.dart';
import 'package:africaonlinestores/features/auth/routing/auth_routes.dart';
import 'package:africaonlinestores/features/catalog/routing/catalog_routes.dart';
import 'package:africaonlinestores/features/home/routing/home_routes.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final authStream = ref.watch(authControllerProvider.notifier).stream;

  return GoRouter(
    initialLocation: AppRoutes.home,

    // Refresh router when auth changes
    refreshListenable: GoRouterRefreshStream(authStream),

    // ✅ IMPORTANT:
    // - Put static/specific route groups before more generic ones.
    // - ALSO ensure inside AdsRoutes.routes() that:
    //   /ads/all/:categoryId is registered BEFORE /ads/:id
    routes: [
      ...HomeRoutes.routes(),
      ...CatalogRoutes.routes(),

      // Ads browse + details (public) + seller routes (protected by redirect below)
      ...AdsRoutes.routes(),

      // Account routes
      ...AccountRoutes.routes(),

      // Auth routes
      ...AuthRoutes.routes(),
    ],

    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Auth pages (block if already logged in)
      final goingToAuth =
          loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.verifyOtp ||
          loc == AppRoutes.forgotPassword ||
          loc == AppRoutes.resetPassword;

      // Public legal pages
      final goingToTerms = loc == AppRoutes.terms;
      final goingToPrivacy = loc == AppRoutes.privacy;

      // Any account page should be protected (except you already allow terms/privacy above)
      final goingToAccount =
          loc == AppRoutes.account || loc.startsWith('/account/');

      // Protect "seller" ads pages (create flow + my ads)
      final goingToSellerAds =
          loc == AppRoutes.myAds ||
          loc == AppRoutes.createAd ||
          loc == AppRoutes.selectCategory ||
          loc == AppRoutes.selectLocation;

      // Allow Terms/Privacy for everyone
      if (goingToTerms || goingToPrivacy) return null;

      // If not logged in, block protected pages
      if (!auth.isLoggedIn && (goingToAccount || goingToSellerAds)) {
        return AppRoutes.login;
      }

      // If logged in, block auth pages
      if (auth.isLoggedIn && goingToAuth) return AppRoutes.home;

      return null;
    },
  );
});

/// Refreshes GoRouter when the provided stream emits.
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
