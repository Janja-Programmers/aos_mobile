import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class MyAdsEmptyView extends StatelessWidget {
  const MyAdsEmptyView({
    super.key,
    required this.onPostFirstAd,
    this.onLearnMore,
  });

  final VoidCallback onPostFirstAd;
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            // Icon Container
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withOpacity(0.06),
                border: Border.all(color: scheme.primary.withOpacity(0.15)),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: context.appColors.textMuted,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text('No Listings Yet', style: context.h3),
            const SizedBox(height: 8),

            // Description
            Text(
              "You haven't posted any ads yet.\n"
              "Start selling by creating your first listing!",
              textAlign: TextAlign.center,
              style: context.p,
            ),

            const SizedBox(height: 18),

            // Primary CTA
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: onPostFirstAd,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: context.appColors.border,
                ),
                label: Text('Post Your First Ad', style: context.button),
              ),
            ),

            const SizedBox(height: 10),

            // Secondary CTA
            TextButton(
              onPressed: onLearnMore,
              style: TextButton.styleFrom(foregroundColor: scheme.primary),
              child: const Text('Learn how to sell faster'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
