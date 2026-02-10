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
  // auth state
  final auth = ref.watch(authControllerProvider);

  // listen to auth changes (StateNotifier stream)
  final authStream = ref.watch(authControllerProvider.notifier).stream;

  return GoRouter(
    initialLocation: AppRoutes.home,

    // ✅ Correct: GoRouter refreshes whenever auth notifier emits
    refreshListenable: GoRouterRefreshStream(authStream),

    routes: [
      ...HomeRoutes.routes(),
      ...CatalogRoutes.routes(),
      ...AdsRoutes.routes(),
      ...AccountRoutes.routes(),
      ...AuthRoutes.routes(),
    ],

    redirect: (context, state) {
      // Home is always landing. We only block auth screens if already logged in.
      final goingToAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.verifyOtp ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.resetPassword;

      final goingToUpdateProfile =
          state.matchedLocation == AppRoutes.updateProfile;
      final goingToPasswordSecurity =
          state.matchedLocation == AppRoutes.passwordSecurity;
      final goingToTerms = state.matchedLocation == AppRoutes.terms;
      final goingToPrivacy = state.matchedLocation == AppRoutes.privacy;

      if (!auth.isLoggedIn &&
          (goingToUpdateProfile || goingToPasswordSecurity)) {
        return AppRoutes.login;
      }

      if (!auth.isLoggedIn && (goingToTerms || goingToPrivacy)) {
        return null;
      }

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
  Future<void> dispose() async {
    await _sub.cancel();
    super.dispose();
  }
}
