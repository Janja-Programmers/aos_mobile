import 'dart:async';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';

/// Promo carousel shown at the top of the home feed.
///
/// Matches the video style: colored promo cards + dots indicator.
/// Kept as a sliver so it can live inside a [CustomScrollView].
class HomeHeroCarouselSection extends StatelessWidget {
  const HomeHeroCarouselSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: _PromoCarousel());
  }
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_index + 1) % _cards.length;
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

  static const _cards = <_PromoCardModel>[
    _PromoCardModel(
      tag: 'HOT',
      title: 'MEGA SALE',
      subtitle: 'Up to 50% Off',
      caption: 'Electronics & Gadgets',
      variant: _PromoCardVariant.red,
      icon: Icons.bolt_rounded,
    ),
    _PromoCardModel(
      tag: 'NEW',
      title: 'FREE DELIVERY',
      subtitle: 'On Orders Above Ksh 2,000',
      caption: 'Limited Time Offer',
      variant: _PromoCardVariant.blue,
      icon: Icons.local_shipping_outlined,
    ),
    _PromoCardModel(
      tag: 'NEW',
      title: 'NEW ARRIVALS',
      subtitle: 'Fresh Products Daily',
      caption: 'Just Landed',
      variant: _PromoCardVariant.teal,
      icon: Icons.new_releases_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        SizedBox(
          height: 132,
          child: PageView.builder(
            controller: _controller,
            itemCount: _cards.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _PromoCard(model: _cards[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_cards.length, (i) {
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

enum _PromoCardVariant { red, blue, teal }

class _PromoCardModel {
  const _PromoCardModel({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.caption,
    required this.variant,
    required this.icon,
  });

  final String tag;
  final String title;
  final String subtitle;
  final String caption;
  final _PromoCardVariant variant;
  final IconData icon;
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.model});

  final _PromoCardModel model;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Color start;
    Color end;
    switch (model.variant) {
      case _PromoCardVariant.red:
        start = const Color(0xFFE94B3C);
        end = const Color(0xFFEF2D56);
        break;
      case _PromoCardVariant.blue:
        start = const Color(0xFF0A84FF);
        end = const Color(0xFF3B82F6);
        break;
      case _PromoCardVariant.teal:
        start = const Color(0xFF10B981);
        end = const Color(0xFF06B6D4);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [start, end],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 14,
            top: 14,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(model.icon, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    model.tag,
                    style: context.pStrong.copyWith(
                      fontSize: 11,
                      color: colors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  model.title,
                  style: context.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  model.subtitle,
                  style: context.pStrong.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  model.caption,
                  style: context.p.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
