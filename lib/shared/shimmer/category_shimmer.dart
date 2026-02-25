import 'package:flutter/material.dart';

import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 72,
      child: Column(
        children: [
          ShimmerBox(width: 50, height: 50, shape: BoxShape.circle),
          SizedBox(height: 8),
          ShimmerBox(width: 60, height: 12),
        ],
      ),
    );
  }
}
