import 'package:africaonlinestores/features/home/presentation/components/brand/home_brand_models.dart';
import 'package:africaonlinestores/features/home/presentation/components/brand/home_mini_category_panel.dart';
import 'package:africaonlinestores/features/home/presentation/components/brand/home_vertical_promoslider.dart';
import 'package:flutter/material.dart';

class HomeBrandSection extends StatelessWidget {
  const HomeBrandSection({
    super.key,
    required this.promos,
    required this.categories,
  });

  final List<HomePromoItem> promos;
  final List<HomeCategoryItem> categories;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 210,
            child: VerticalPromoSlider(items: promos),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 210,
            child: MiniCategoryPanel(items: categories),
          ),
        ),
      ],
    );
  }
}
