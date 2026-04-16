import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/widgets/feed_filter_menu.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          /// 🔍 Search
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.black),
                  const SizedBox(width: 8),
                  Text('Search', style: TextStyle(color: colors.black)),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// Filter
          const FeedFilterMenu(),

          const SizedBox(width: 8),

          /// Notification
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
