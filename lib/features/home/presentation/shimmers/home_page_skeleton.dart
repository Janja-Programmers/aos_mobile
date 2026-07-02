import 'package:africaonlinestores/features/home/presentation/shimmers/categories_preview_shimmer.dart';
import 'package:africaonlinestores/features/home/presentation/shimmers/grid_ads_section_shimmer.dart';
import 'package:africaonlinestores/features/home/presentation/shimmers/hero_carousel_shimmer.dart';
import 'package:africaonlinestores/features/home/presentation/shimmers/horizontal_ads_section_shimmer.dart';
import 'package:flutter/material.dart';

class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        HeroCarouselShimmer(),
        CategoriesPreviewShimmer(),
        HorizontalAdsSectionShimmer(title: 'Flash Sales'),
        GridAdsSectionShimmer(title: 'New Products'),
        HorizontalAdsSectionShimmer(title: 'Deals'),
      ],
    );
  }
}
