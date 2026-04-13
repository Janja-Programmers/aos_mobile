import 'package:flutter/material.dart';

class AnimatedBrandText extends StatelessWidget {
  const AnimatedBrandText({super.key, required this.controller});

  final AnimationController controller;

  static const _letters = [
    'A',
    'f',
    'r',
    'i',
    'c',
    'a',
    'O',
    'n',
    'l',
    'i',
    'n',
    'e',
    'S',
    't',
    'o',
    'r',
    'e',
    's',
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// ---------- ROW 1: AOS ----------
          _buildAOS(),

          const SizedBox(height: 16),

          /// ---------- ROW 2: LINE ----------
          _buildLine(primary),

          const SizedBox(height: 20),

          /// ---------- ROW 3: LETTERS ----------
          _buildLetters(),
        ],
      ),
    );
  }

  /// ---------- AOS (FIRST ANIMATION) ----------
  Widget _buildAOS() {
    final animation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value;

        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 40),
            child: Transform.scale(scale: 0.8 + (0.2 * v), child: child),
          ),
        );
      },
      child: const Text(
        'AOS',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }

  /// ---------- LINE (SECOND ANIMATION) ----------
  Widget _buildLine(Color color) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value;

        return Opacity(
          opacity: v,
          child: Transform.scale(scaleX: v, child: child),
        );
      },
      child: Container(
        height: 3,
        width: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// ---------- LETTERS (THIRD ANIMATION) ----------
  Widget _buildLetters() {
    const baseStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5,
    );

    final total = _letters.length;
    final step = 1.0 / total;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 6,
      children: List.generate(_letters.length, (index) {
        final start = 0.5 + (index * step * 0.8);
        final end = (start + step * 1.5).clamp(0.0, 1.0);

        final animation = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.elasticOut),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final v = animation.value;

            return Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 30),
                child: Transform.scale(scale: 0.8 + (0.2 * v), child: child),
              ),
            );
          },
          child: Text(_letters[index], style: baseStyle),
        );
      }),
    );
  }
}
