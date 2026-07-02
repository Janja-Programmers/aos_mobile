import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';
import 'package:flutter/material.dart';

class CategoriesPreviewShimmer extends StatelessWidget {
  const CategoriesPreviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(
                    height: 18,
                    width: 120,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                ShimmerBox(
                  height: 16,
                  width: 60,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Categories row
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) => const Column(
                  children: [
                    ShimmerBox(width: 58, height: 58, shape: BoxShape.circle),
                    SizedBox(height: 8),
                    ShimmerBox(width: 60, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
