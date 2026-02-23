import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';

class GridAdsSectionShimmer extends StatelessWidget {
  const GridAdsSectionShimmer({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(child: Text(title, style: context.h5)),
                Text(
                  "See all",
                  style: context.pStrong.copyWith(
                    color: context.appColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, _) => const ShimmerBox(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}
