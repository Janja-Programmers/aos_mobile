import 'dart:math';
import 'package:flutter/material.dart';

class SplashBubbles extends StatefulWidget {
  const SplashBubbles({super.key});

  @override
  State<SplashBubbles> createState() => _SplashBubblesState();
}

class _SplashBubblesState extends State<SplashBubbles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return CustomPaint(
          painter: _BubblePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  final double progress;

  _BubblePainter(this.progress);

  static const bubbles = [
    _BubbleSpec(0.1, 0.35, 10),
    _BubbleSpec(0.15, 0.4, 7),
    _BubbleSpec(0.2, 0.6, 8),
    _BubbleSpec(0.25, 0.7, 12),
    _BubbleSpec(0.3, 0.3, 6),
    _BubbleSpec(0.7, 0.3, 9),
    _BubbleSpec(0.75, 0.4, 6),
    _BubbleSpec(0.8, 0.6, 11),
    _BubbleSpec(0.85, 0.7, 13),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD01F28).withOpacity(0.06)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < bubbles.length; i++) {
      final b = bubbles[i];

      final dx = b.x * size.width;
      final baseY = b.y * size.height;

      /// subtle floating motion
      final floatY = sin(progress * 2 * pi + i) * 6;
      final floatX = cos(progress * 2 * pi + i) * 3;

      canvas.drawCircle(Offset(dx + floatX, baseY + floatY), b.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BubbleSpec {
  final double x;
  final double y;
  final double radius;

  const _BubbleSpec(this.x, this.y, this.radius);
}
