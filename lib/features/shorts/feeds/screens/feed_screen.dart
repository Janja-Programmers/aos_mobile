import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/providers/feed_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/widgets/feed_header.dart';
import 'package:africaonlinestores/features/shorts/feeds/widgets/feed_tabs.dart';
import 'package:africaonlinestores/features/shorts/feeds/widgets/inspiration_grid.dart';
import 'package:africaonlinestores/features/shorts/feeds/widgets/following_section.dart';
import 'package:africaonlinestores/features/shorts/feeds/widgets/saved_empty_state.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(feedTabProvider);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const FeedHeader(),
            const FeedTabs(),

            Expanded(
              child: IndexedStack(
                index: currentTab.index,
                children: const [
                  InspirationGrid(),
                  FollowingSection(),
                  SavedEmptyState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
