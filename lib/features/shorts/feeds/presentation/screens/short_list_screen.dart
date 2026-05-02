import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/shorts_feed_tab.dart';
import 'package:flutter/material.dart';

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
          title: Text('Shorts', style: context.h5),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'For You',
                  style: context.h6.copyWith(color: colors.primary),
                ),
              ),
              Tab(
                child: Text(
                  'Following',
                  style: context.h6.copyWith(color: colors.primary),
                ),
              ),
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
