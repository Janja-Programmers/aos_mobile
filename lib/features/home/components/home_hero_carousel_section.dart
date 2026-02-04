import 'dart:async';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

/// Top carousel section (3 images + animated dots indicator).
///
/// This is kept as a sliver so it can be placed inside a CustomScrollView.
class HomeHeroCarouselSection extends StatelessWidget {
  const HomeHeroCarouselSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: _HeroCarousel());
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  // Using stable public images.
  static const _images = <String>[
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=1400&q=80',
  ];

  @override
  void initState() {
    super.initState();

    // Auto-advance.
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_index + 1) % _images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        SizedBox(
          height: 132,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _controller,
              // RTL carousel feel.
              reverse: true,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colors.surface,
                        alignment: Alignment.center,
                        child: Icon(Icons.image, color: colors.textMuted),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? colors.primary : colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}
