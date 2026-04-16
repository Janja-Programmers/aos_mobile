import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';

import 'package:africaonlinestores/app/splash/widgets/orbit_system.dart';
import 'package:africaonlinestores/app/splash/widgets/splash_bubbles.dart';
import 'package:africaonlinestores/app/splash/widgets/splash_text.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const totalDuration = Duration(seconds: 8);

  late final AnimationController _controller;
  late final AnimationController _exitController;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: totalDuration)
      ..forward();

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1,
    );

    Future.delayed(totalDuration, _tryNavigate);
  }

  Future<void> _tryNavigate() async {
    if (_navigated || !mounted) return;

    final auth = ref.read(authControllerProvider);
    final bootstrap = ref.read(appBootstrapProvider);

    if (bootstrap.isReady != true || auth is AuthLoading) return;

    _navigated = true;

    await _exitController.reverse();

    if (!mounted) return;
    await Navigator.pushReplacementNamed(context, _resolveRoute(auth));
  }

  String _resolveRoute(AuthState auth) {
    if (auth is AuthAuthenticated) return '/home';
    return '/login';
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _exitController,
        child: Stack(
          children: [
            const SplashBubbles(),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OrbitSystem(controller: _controller),

                  const SizedBox(height: 40),

                  SplashText(controller: _controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
