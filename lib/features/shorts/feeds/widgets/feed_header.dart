import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/feed_search_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/widgets/feed_filter_menu.dart';

import 'package:africaonlinestores/features/notifications/navigation/notification_routes.dart';

class FeedHeader extends ConsumerWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final searchController = ref.read(feedSearchControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          /// 🔍 SEARCH INPUT
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',

                  border: InputBorder.none,

                  icon: Icon(Icons.search, color: colors.black),
                ),

                onChanged: (value) {
                  searchController.onQueryChanged(ref, value);
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          const FeedFilterMenu(),

          const SizedBox(width: 8),

          /// Notifications
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () => NotificationsNavigation.toNotification(context),
            ),
          ),
        ],
      ),
    );
  }
}
