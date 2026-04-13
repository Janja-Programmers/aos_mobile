import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final bootstrap = ref.watch(appBootstrapProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// LOGO / BRAND
            const FlutterLogo(size: 80),

            const SizedBox(height: 24),

            /// STATUS TEXT (optional debug)
            Text(
              _statusText(auth, bootstrap),
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            /// LOADER
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  String _statusText(AuthState auth, bootstrap) {
    if (!bootstrap.isReady) {
      return 'Initializing app...';
    }

    if (auth is AuthLoading) {
      return 'Checking session...';
    }

    if (auth is AuthGuest) {
      return 'Preparing guest session...';
    }

    if (auth is AuthAuthenticated) {
      return 'Welcome back...';
    }

    return 'Loading...';
  }
}
