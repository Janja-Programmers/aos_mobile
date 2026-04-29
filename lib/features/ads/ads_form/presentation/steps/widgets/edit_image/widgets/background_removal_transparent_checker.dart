import 'package:flutter/material.dart';

class TransparentChecker extends StatelessWidget {
  const TransparentChecker({
    super.key,
    this.size = 8,
    this.light = const Color(0xFFE0E0E0),
    this.dark = const Color(0xFFBDBDBD),
  });

  final double size;
  final Color light;
  final Color dark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerPainter(size, light, dark),
      size: Size.infinite,
    );
  }
}

class _CheckerPainter extends CustomPainter {
  _CheckerPainter(this.size, this.light, this.dark);

  final double size;
  final Color light;
  final Color dark;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint();

    for (double y = 0; y < canvasSize.height; y += size) {
      for (double x = 0; x < canvasSize.width; x += size) {
        final isDark = ((x ~/ size) + (y ~/ size)) % 2 == 0;

        paint.color = isDark ? dark : light;

        canvas.drawRect(Rect.fromLTWH(x, y, size, size), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
