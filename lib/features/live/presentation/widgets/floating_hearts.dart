import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class FloatingHearts extends StatefulWidget {
  final int trigger;

  const FloatingHearts({super.key, required this.trigger});

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with SingleTickerProviderStateMixin {
  final List<_HeartItem> hearts = [];

  @override
  void didUpdateWidget(covariant FloatingHearts oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.trigger != oldWidget.trigger) {
      _addHeart();
    }
  }

  void _addHeart() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      hearts.add(_HeartItem(id));
    });

    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      setState(() {
        hearts.removeWhere((h) => h.id == id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 30,
      bottom: 180,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: hearts.map((heart) {
            return TweenAnimationBuilder<double>(
              key: ValueKey(heart.id),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOut,
              builder: (_, value, child) {
                return Transform.translate(
                  offset: Offset(heart.xOffset, -value * 180),
                  child: Opacity(
                    opacity: 1 - value,
                    child: Transform.scale(
                      scale: 0.7 + value,
                      child: Icon(
                        Icons.favorite,
                        color: context.appColors.primary,
                        size: 34,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HeartItem {
  final String id;
  final double xOffset;

  _HeartItem(this.id) : xOffset = (DateTime.now().millisecond % 40) - 20;
}
