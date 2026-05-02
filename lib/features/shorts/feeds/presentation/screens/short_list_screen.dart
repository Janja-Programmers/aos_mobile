import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/feed_header.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/shorts_feed_tab.dart';

class ShortListScreen extends StatelessWidget {
  const ShortListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          titleSpacing: 0,
          title: const FeedHeader(),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ShortsFeedTab(feedType: ShortsFeedType.forYou),
            ShortsFeedTab(feedType: ShortsFeedType.following),
          ],
        ),
      ),
    );
  }
}
