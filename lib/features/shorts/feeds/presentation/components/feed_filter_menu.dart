import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/providers/feed_providers.dart';

class FeedFilterMenu extends ConsumerWidget {
  const FeedFilterMenu({super.key});

  String label(FeedFilter filter) {
    switch (filter) {
      case FeedFilter.all:
        return 'All';
      case FeedFilter.live:
        return 'Live';
      case FeedFilter.photos:
        return 'Photos';
      case FeedFilter.shorts:
        return 'Shorts';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(feedFilterProvider);
    final colors = context.appColors;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FeedFilter>(
          value: filter,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: FeedFilter.values.map((f) {
            return DropdownMenuItem(value: f, child: Text(label(f)));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(feedFilterProvider.notifier).state = value;
            }
          },
        ),
      ),
    );
  }
}
