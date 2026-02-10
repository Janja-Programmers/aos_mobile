import 'package:africaonlinestores/features/home/components/home_brand_categories_card.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/home/components/home_brand_models.dart';
import 'package:africaonlinestores/features/home/components/home_brand_promo_carousel.dart';

export 'home_brand_models.dart';

/// Home section:
/// - Left: vertical carousel (3 promos) sliding bottom->top
/// - Right: dynamic category pills
class HomeBrandSection extends StatelessWidget {
  const HomeBrandSection({
    super.key,
    required this.promos,
    required this.categories,
    this.height = 200,
    this.gap = 12,
  });

  final List<HomePromoItem> promos;
  final List<HomeCategoryItem> categories;
  final double height;
  final double gap;

  @override
  Widget build(BuildContext context) {
    const radius = 22.0;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: HomeBrandPromoCarousel(
              items: promos,
              borderRadius: BorderRadius.circular(radius),
              height: height,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: HomeBrandCategoriesCard(
              items: categories,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ],
      ),
    );
  }
}
