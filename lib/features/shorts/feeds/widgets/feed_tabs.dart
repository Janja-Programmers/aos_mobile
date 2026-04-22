import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/providers/feed_providers.dart';

class FeedTabs extends ConsumerWidget {
  const FeedTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(feedTabProvider);
    final colors = context.appColors;

    Widget buildTab(String label, FeedTab tab) {
      final isActive = currentTab == tab;

      return GestureDetector(
        onTap: () => ref.read(feedTabProvider.notifier).state = tab,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: 40,
              color: isActive ? colors.primary : Colors.transparent,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTab('Inspiration', FeedTab.inspiration),
              buildTab('Following', FeedTab.following),
              buildTab('Saved', FeedTab.saved),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
