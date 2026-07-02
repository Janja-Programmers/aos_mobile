import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_models.dart';
import 'package:flutter/material.dart';

class VerticalPromoSlider extends StatelessWidget {
  const VerticalPromoSlider({super.key, required this.items});

  final List<HomePromoItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (items.isEmpty) return const SizedBox.shrink();

    final promo = items.first; // simple version (can make carousel later)

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [promo.color, promo.color.withValues(alpha: 0.7)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              promo.icon,
              size: 120,
              color: colors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                promo.title,
                style: context.subtitle.copyWith(color: colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                promo.subtitle,
                style: AppTextStylesX(
                  context,
                ).caption.copyWith(color: colors.white.withValues(alpha: 0.9)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  promo.ctaText,
                  style: AppTextStylesX(context).caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
