import 'dart:async';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

/// Promo carousel shown at the top of the home feed.
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

  static const _cards = <_PromoCardModel>[
    _PromoCardModel(
      tag: 'HOT',
      title: 'MEGA SALE',
      subtitle: 'Up to 50% Off',
      description: 'Electronics & Gadgets',
      start: Color(0xFFE53935),
      end: Color(0xFFFF7043),
      icon: Icons.bolt_rounded,
    ),
    _PromoCardModel(
      tag: 'NEW',
      title: 'FREE DELIVERY',
      subtitle: 'Orders Above Ksh 2,000',
      description: 'Limited Time Offer',
      start: Color(0xFF1E88E5),
      end: Color(0xFF42A5F5),
      icon: Icons.local_shipping_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_index + 1) % _cards.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
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
          height: 140, // SPEC
          child: PageView.builder(
            controller: _controller,
            itemCount: _cards.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _PromoCard(model: _cards[i]),
          ),
        ),
        const SizedBox(height: 12),

        /// Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_cards.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 24 : 8,
              height: 8,
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

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.model});

  final _PromoCardModel model;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [model.start, model.end],
        ),
      ),
      child: Stack(
        children: [
          /// Background watermark icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              model.icon,
              size: 120,
              color: colors.white.withOpacity(0.1),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    model.tag,
                    style: AppTextStylesX(context).caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: model.start,
                    ),
                  ),
                ),

                const Spacer(),

                /// Title
                Text(
                  model.title,
                  style: context.headline.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.white,
                  ),
                ),

                const SizedBox(height: 2),

                /// Subtitle
                Text(
                  model.subtitle,
                  style: context.subtitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 2),

                /// Description
                Text(
                  model.description,
                  style: context.body.copyWith(
                    fontSize: 12,
                    color: colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          /// Foreground icon container
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(model.icon, size: 28, color: colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCardModel {
  const _PromoCardModel({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.start,
    required this.end,
    required this.icon,
  });

  final String tag;
  final String title;
  final String subtitle;
  final String description;
  final Color start;
  final Color end;
  final IconData icon;
}
