import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashRingPainter extends CustomPainter {
  SplashRingPainter({required this.rotation});

  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    /// ---------- BASE RING ----------
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawCircle(center, radius - 6, basePaint);

    /// ---------- BREATHING EFFECT ----------
    final breathing = 1 + (0.15 * math.sin(rotation * 2 * math.pi));

    /// ---------- MAIN GLOW ARC ----------
    final rect = Rect.fromCircle(center: center, radius: radius - 6);

    final glowPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: const [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.6, 1.0],
        transform: GradientRotation(2 * math.pi * rotation),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * breathing
      ..strokeCap = StrokeCap.round;

    final startAngle1 = -math.pi / 2;
    final sweepAngle1 = math.pi * 1.2;

    canvas.drawArc(rect, startAngle1, sweepAngle1, false, glowPaint);

    /// ---------- ACCENT ARC (INNER) ----------
    final innerRect = Rect.fromCircle(center: center, radius: radius - 16);

    final accentPaint = Paint()
      ..color = const Color(0xFFBFA46F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * breathing
      ..strokeCap = StrokeCap.round;

    final startAngle2 = (2 * math.pi * rotation) - math.pi / 3;

    final sweepAngle2 = math.pi * 0.5;

    canvas.drawArc(innerRect, startAngle2, sweepAngle2, false, accentPaint);

    /// ---------- OPTIONAL: SMALL ORBIT DOT ----------
    final dotAngle = 2 * math.pi * rotation;
    final dotRadius = radius - 6;

    final dotOffset = Offset(
      center.dx + dotRadius * math.cos(dotAngle),
      center.dy + dotRadius * math.sin(dotAngle),
    );

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dotOffset, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant SplashRingPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
