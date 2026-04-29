import 'dart:math' as math;

import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const List<IconData> _kWheelIcons = [
  Icons.public,
  Icons.shopping_cart_outlined,
  Icons.local_shipping_outlined,
  Icons.flight_takeoff,
  Icons.location_on_outlined,
  Icons.storefront_outlined,
  Icons.language,
  Icons.inventory_2_outlined,
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _ringController;
  late final AnimationController _textController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _ringRotation;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;

  bool _showRing = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _setupAnimations();
    _play();
  }

  void _setupAnimations() {
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );

    _logoScale = Tween<double>(begin: .72, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Cubic(.20, 1.35, .35, 1),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _ringScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: .15,
          end: 1.04,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.04,
          end: .96,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: .96,
          end: 1.02,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.02,
          end: .72,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 30,
      ),
    ]).animate(_ringController);

    _ringOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 22,
      ),
      TweenSequenceItem(tween: ConstantTween(1), weight: 54),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 24,
      ),
    ]).animate(_ringController);

    _ringRotation = Tween<double>(begin: 0, end: math.pi * .42).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOutCubic),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );

    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    );

    _textOffset = Tween<Offset>(begin: const Offset(0, .20), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );
  }

  Future<void> _play() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    await _entryController.forward();

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    setState(() => _showRing = true);
    await _ringController.forward();

    if (!mounted) return;
    setState(() => _showText = true);
    await _textController.forward();

    // Do not navigate here.
    // GoRouter.redirect owns routing once bootstrap/auth becomes ready.
  }

  @override
  void dispose() {
    _entryController.dispose();
    _ringController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final ringRadius = (width * .34).clamp(118.0, 164.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _entryController,
            _ringController,
            _textController,
          ]),
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const _SplashBackground(),
                if (_showRing)
                  Center(
                    child: Opacity(
                      opacity: _ringOpacity.value.clamp(0, 1),
                      child: Transform.rotate(
                        angle: _ringRotation.value,
                        child: Transform.scale(
                          scale: _ringScale.value,
                          child: _OrbitWheel(radius: ringRadius),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: _CenterBrand(
                    logoScale: _logoScale.value,
                    logoOpacity: _logoOpacity.value,
                    showText: _showText,
                    textOpacity: _textOpacity.value,
                    textOffset: _textOffset.value,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CenterBrand extends StatelessWidget {
  final double logoScale;
  final double logoOpacity;
  final bool showText;
  final double textOpacity;
  final Offset textOffset;

  const _CenterBrand({
    required this.logoScale,
    required this.logoOpacity,
    required this.showText,
    required this.textOpacity,
    required this.textOffset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: logoOpacity.clamp(0, 1),
          child: Transform.scale(
            scale: logoScale,
            child: Container(
              width: 116,
              height: 116,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withAlpha(28),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo_redone.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) {
                  return Image.asset(
                    'assets/images/aos_logo.png',
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 30),
          Opacity(
            opacity: textOpacity.clamp(0, 1),
            child: FractionalTranslation(
              translation: textOffset,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AOS',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF171717),
                      letterSpacing: 15,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AFRICA ONLINE STORES',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF777777),
                      letterSpacing: 4.6,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrbitWheel extends StatelessWidget {
  final double radius;

  const _OrbitWheel({required this.radius});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = radius * 2 + 104;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WheelPainter(
          ringRadius: radius,
          iconCount: _kWheelIcons.length,
          primaryColor: colors.primary,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(_kWheelIcons.length, (index) {
            final angle =
                -math.pi / 2 + (2 * math.pi * index / _kWheelIcons.length);
            final dx = radius * math.cos(angle);
            final dy = radius * math.sin(angle);

            return Transform.translate(
              offset: Offset(dx, dy),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.96),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withAlpha(26),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  _kWheelIcons[index],
                  color: colors.primary,
                  size: 21,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF6F6),
            Color(0xFFFBF1F1),
            Color(0xFFF5FAF5),
            Color(0xFFFFFFFF),
          ],
          stops: [0, .36, .72, 1],
        ),
      ),
      child: CustomPaint(painter: _KenyanAccentPainter()),
    );
  }
}

class _KenyanAccentPainter extends CustomPainter {
  const _KenyanAccentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF000000).withAlpha(58),
        const Color(0xFF000000).withAlpha(0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h * .30));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * .30), paint);

    paint.shader = null;
    paint.color = Colors.white.withAlpha(118);
    canvas.drawRect(Rect.fromLTWH(0, h * .265, w, h * .022), paint);

    paint.shader = RadialGradient(
      center: Alignment.center,
      radius: .82,
      colors: [
        const Color(0xFFC1121F).withAlpha(70),
        const Color(0xFFC1121F).withAlpha(0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    paint.shader = null;
    paint.color = Colors.white.withAlpha(110);
    canvas.drawRect(Rect.fromLTWH(0, h * .712, w, h * .022), paint);

    paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF006600).withAlpha(62),
        const Color(0xFF006600).withAlpha(0),
      ],
    ).createShader(Rect.fromLTWH(0, h * .70, w, h * .30));
    canvas.drawRect(Rect.fromLTWH(0, h * .70, w, h * .30), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WheelPainter extends CustomPainter {
  final double ringRadius;
  final int iconCount;
  final Color primaryColor;

  const _WheelPainter({
    required this.ringRadius,
    required this.iconCount,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final ringPaint = Paint()
      ..color = primaryColor.withAlpha(86)
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, ringRadius, ringPaint);

    final spokePaint = Paint()
      ..color = primaryColor.withAlpha(42)
      ..strokeWidth = .85
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const innerRadius = 58.0;
    final outerRadius = ringRadius - 24;

    for (var i = 0; i < iconCount; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / iconCount);

      canvas.drawLine(
        Offset(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        ),
        Offset(
          center.dx + outerRadius * math.cos(angle),
          center.dy + outerRadius * math.sin(angle),
        ),
        spokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.ringRadius != ringRadius ||
        oldDelegate.iconCount != iconCount ||
        oldDelegate.primaryColor != primaryColor;
  }
}
