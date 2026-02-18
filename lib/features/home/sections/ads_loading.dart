import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/widgets/app_shimmer.dart';

class AdListLoadingView extends StatelessWidget {
  const AdListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const ShimmerBox(height: 120),
    );
  }
}
