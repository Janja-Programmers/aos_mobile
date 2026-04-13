import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/app/splash/widgets/animated_brand_text.dart';
import 'package:africaonlinestores/app/splash/widgets/splash_ring_painter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _minimumSplashTime = Duration(minutes: 1);

  late final AnimationController _ringRotationController;
  late final AnimationController _pulseController;
  late final AnimationController _textController;

  Timer? _timer;
  bool _minimumTimeElapsed = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _ringRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
      lowerBound: 0.85,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _timer = Timer(_minimumSplashTime, () {
      _minimumTimeElapsed = true;
      _tryNavigate();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringRotationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _tryNavigate() {
    if (!mounted || _navigated) return;

    final auth = ref.read(authControllerProvider);
    final bootstrap = ref.read(appBootstrapProvider);

    final bootstrapReady = bootstrap.isReady == true;
    final authResolved = auth is! AuthLoading;

    if (!_minimumTimeElapsed || !bootstrapReady || !authResolved) {
      return;
    }

    _navigated = true;

    final route = _resolveRoute(auth);
    Navigator.of(context).pushReplacementNamed(route);
  }

  String _resolveRoute(AuthState auth) {
    if (auth is AuthAuthenticated) {}

    if (auth is AuthGuest) {}

    return '';
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryNavigate();
    });

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Column(
          children: [
            /// ---------- TOP HALF ----------
            Expanded(
              child: Center(
                child: Container(
                  width: 220,
                  height: 220,
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _ringRotationController,
                      _pulseController,
                    ]),
                    child: _buildLogo(),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseController.value,
                        child: CustomPaint(
                          painter: SplashRingPainter(
                            rotation: _ringRotationController.value,
                          ),
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(child: child),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// ---------- BOTTOM HALF ----------
            Expanded(child: AnimatedBrandText(controller: _textController)),
          ],
        ),
      ),
    );
  }
}

Widget _buildLogo() {
  return Container(
    width: 96,
    height: 96,
    decoration: const BoxDecoration(shape: BoxShape.circle),
    child: ClipOval(
      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
    ),
  );
}
