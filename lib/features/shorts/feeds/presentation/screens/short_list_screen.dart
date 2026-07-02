import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/short_upload_progress_banner.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/feed_header.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/feed_category_chips.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/shorts_feed_tab.dart';
import 'package:flutter/material.dart';

class ShortListScreen extends StatefulWidget {
  const ShortListScreen({super.key});

  @override
  State<ShortListScreen> createState() => _ShortListScreenState();
}

class _ShortListScreenState extends State<ShortListScreen> {
  String _selectedCategoryId = 'all';
  String _selectedCategoryLabel = 'All';
  String? _selectedContentMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return AnimatedBuilder(
            animation: tabController,
            builder: (context, _) {
              final isLiveTab = tabController.index == 2;

              return Scaffold(
                backgroundColor: colors.surface,
                appBar: AppBar(
                  titleSpacing: 0,
                  title: const FeedHeader(),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'For You'),
                      Tab(text: 'Following'),
                      Tab(text: 'Live'),
                    ],
                  ),
                ),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        if (!isLiveTab) ...[
                          const SizedBox(height: 8),
                          FeedCategoryChips(
                            selectedId: _selectedCategoryId,
                            onSelected: (option) {
                              setState(() {
                                _selectedCategoryId = option.id;
                                _selectedCategoryLabel = option.label;
                                _selectedContentMode = option.contentMode;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                        Expanded(
                          child: TabBarView(
                            children: [
                              ShortsFeedTab(
                                feedType: ShortsFeedType.forYou,
                                contentMode: _selectedContentMode,
                                categoryLabel: _selectedCategoryLabel,
                              ),
                              ShortsFeedTab(
                                feedType: ShortsFeedType.following,
                                contentMode: _selectedContentMode,
                                categoryLabel: _selectedCategoryLabel,
                              ),
                              const ShortsFeedTab(
                                feedType: ShortsFeedType.live,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ShortUploadProgressBanner(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
