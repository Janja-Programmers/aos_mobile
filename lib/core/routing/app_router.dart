import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/features/auth/providers/auth_controller.dart';
import 'package:aos_mobile/features/auth/ui/login_screen.dart';
import 'package:aos_mobile/features/auth/ui/register_screen.dart';
import 'package:aos_mobile/features/auth/ui/verify_otp_screen.dart';
import 'package:aos_mobile/features/home/ui/home_screen.dart';
import 'package:aos_mobile/core/routing/app_routes.dart';

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
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          final prefillEmail = state.uri.queryParameters['email'];
          return LoginScreen(prefillEmail: prefillEmail);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) {
          final email = (state.extra is String) ? state.extra as String : '';
          return VerifyOTPScreen(email: email);
        },
      ),
    ],

    redirect: (context, state) {
      // Home is always landing. We only block auth screens if already logged in.
      final goingToAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.verifyOtp;

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
