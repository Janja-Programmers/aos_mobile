import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';

class AdCardShimmer extends StatelessWidget {
  const AdCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.border,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
