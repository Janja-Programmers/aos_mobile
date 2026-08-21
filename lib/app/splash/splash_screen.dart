import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kPrimaryRed = Color(0xFFC1121F);
const Color _kKenyaGreen = Color(0xFF0B7A3B);
const int _kProgressDurationMs = 2080;

const SystemUiOverlayStyle _kSplashSystemUiStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0xFF08090C),
  systemNavigationBarIconBrightness: Brightness.light,
);

const SystemUiOverlayStyle _kErrorSystemUiStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _revealController;
  late final AnimationController _progressController;
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kProgressDurationMs),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_revealController.forward());
      unawaited(_progressController.forward());
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _progressController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authControllerProvider);
    if (authState is AuthRestorationFailure) {
      return _SessionRestorationUnavailable(reason: authState.reason);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _kSplashSystemUiStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFF08090C),
        body: RepaintBoundary(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.24),
                radius: 1.2,
                colors: [
                  Color(0xFF1B1C22),
                  Color(0xFF101116),
                  Color(0xFF08090C),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _AmbientBlobs(animation: _ambientController),
                _CenterBrand(
                  revealAnimation: _revealController,
                  ambientAnimation: _ambientController,
                ),
                _SplashProgress(animation: _progressController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientBlobs extends StatelessWidget {
  const _AmbientBlobs({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final double phase = animation.value * 2 * math.pi;
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -80 + 12 * math.sin(phase),
                left: -70 + 16 * math.sin(phase + 1.2),
                child: const _BlurredBlob(
                  size: 360,
                  color: _kPrimaryRed,
                  alpha: 0x2E,
                ),
              ),
              Positioned(
                right: -90 + 12 * math.sin(phase + 0.6),
                bottom: -110 + 12 * math.sin(phase + 2.1),
                child: const _BlurredBlob(
                  size: 340,
                  color: _kKenyaGreen,
                  alpha: 0x26,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlurredBlob extends StatelessWidget {
  const _BlurredBlob({
    required this.size,
    required this.color,
    required this.alpha,
  });

  final double size;
  final Color color;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withAlpha(alpha), color.withAlpha(0)],
            stops: const [0, 0.62],
          ),
        ),
      ),
    );
  }
}

class _CenterBrand extends StatelessWidget {
  const _CenterBrand({
    required this.revealAnimation,
    required this.ambientAnimation,
  });

  final Animation<double> revealAnimation;
  final Animation<double> ambientAnimation;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([revealAnimation, ambientAnimation]),
        builder: (context, _) {
          final double reveal = Curves.easeOut.transform(revealAnimation.value);
          final double revealScale = 0.9 + 0.1 * reveal;
          final double blur = (1 - reveal) * 10;
          final double pulse =
              0.5 + 0.5 * math.sin(ambientAnimation.value * 2 * math.pi);
          final double glowOpacity = (0.55 + 0.25 * pulse) * reveal;
          final double glowScale = 1 + 0.06 * pulse;

          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 88),
              child: Semantics(
                image: true,
                label: 'Africa Online Stores. Brings people together.',
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 168,
                        height: 168,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: glowOpacity.clamp(0, 1),
                              child: Transform.scale(
                                scale: glowScale,
                                child: const _LogoGlow(),
                              ),
                            ),
                            Opacity(
                              opacity: reveal.clamp(0, 1),
                              child: Transform.scale(
                                scale: revealScale,
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: blur,
                                    sigmaY: blur,
                                  ),
                                  child: Image.asset(
                                    'assets/images/logo_redone.png',
                                    width: 168,
                                    height: 168,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) {
                                      return Image.asset(
                                        'assets/images/aos_logo.png',
                                        width: 168,
                                        height: 168,
                                        fit: BoxFit.contain,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Opacity(
                        opacity: reveal.clamp(0, 1),
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - reveal)),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'BRINGS PEOPLE TOGETHER',
                                maxLines: 1,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 4,
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoGlow extends StatelessWidget {
  const _LogoGlow();

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: 220,
      maxHeight: 220,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [_kPrimaryRed.withAlpha(0x3A), _kPrimaryRed.withAlpha(0)],
            stops: const [0, 0.68],
          ),
        ),
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final double bottom = (MediaQuery.sizeOf(context).height * 0.09).clamp(
      48,
      120,
    );
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: bottom),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Semantics(
              label: 'Loading',
              value: '${(animation.value * 100).round()}%',
              child: SizedBox(
                width: 132,
                height: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      ColoredBox(
                        color: Colors.white.withValues(alpha: 0.10),
                        child: const SizedBox.expand(),
                      ),
                      FractionallySizedBox(
                        widthFactor: Curves.easeInOut.transform(
                          animation.value,
                        ),
                        alignment: Alignment.centerLeft,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_kPrimaryRed, Color(0xFFE63946)],
                            ),
                          ),
                          child: SizedBox.expand(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionRestorationUnavailable extends ConsumerWidget {
  const _SessionRestorationUnavailable({required this.reason});

  final AuthRestorationFailureReason reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool isConnectivityIssue =
        reason == AuthRestorationFailureReason.network ||
        reason == AuthRestorationFailureReason.timeout;
    final String title = isConnectivityIssue
        ? localizations.session_restore_offline_title
        : localizations.session_restore_unavailable_title;
    final String message = isConnectivityIssue
        ? localizations.session_restore_offline_message
        : localizations.session_restore_unavailable_message;
    final ThemeData theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _kErrorSystemUiStyle,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0, constraints.maxHeight - 48),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Semantics(
                        container: true,
                        liveRegion: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isConnectivityIssue
                                  ? Icons.cloud_off_outlined
                                  : Icons.sync_problem_outlined,
                              size: 64,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 28),
                            FilledButton.icon(
                              onPressed: () {
                                unawaited(
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .retrySessionRestoration(),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(localizations.common_try_again),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
