import 'package:flutter/material.dart';
import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';

class HeroCarouselShimmer extends StatelessWidget {
  const HeroCarouselShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      sliver: SliverToBoxAdapter(
        child: ShimmerBox(height: 132, borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
