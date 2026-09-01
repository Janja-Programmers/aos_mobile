import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/short_upload_progress_banner.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/feed_header.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_l10n.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/feed_category_chips.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/shorts_feed_tab.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class ShortListScreen extends StatefulWidget {
  const ShortListScreen({super.key});

  @override
  State<ShortListScreen> createState() => _ShortListScreenState();
}

class _ShortListScreenState extends State<ShortListScreen> {
  String _selectedCategoryId = 'all';
  String? _selectedContentMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final useScrollableTabs = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final selectedCategory = feedCategoryOptions.firstWhere(
      (option) => option.id == _selectedCategoryId,
      orElse: () => feedCategoryOptions.first,
    );

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
                  toolbarHeight: 68,
                  titleSpacing: 0,
                  title: const FeedHeader(),
                  bottom: TabBar(
                    isScrollable: useScrollableTabs,
                    indicatorColor: colors.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    dividerColor: colors.border.withValues(alpha: .65),
                    labelColor: colors.textPrimary,
                    unselectedLabelColor: colors.textMuted,
                    labelStyle: context.p.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelStyle: context.p.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: l10n.feedForYou),
                      Tab(text: l10n.feedFollowing),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(l10n.feedLive),
                          ],
                        ),
                      ),
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
                              if (_selectedCategoryId == option.id) return;
                              setState(() {
                                _selectedCategoryId = option.id;
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
                                categoryLabel: selectedCategory.label(context),
                              ),
                              ShortsFeedTab(
                                feedType: ShortsFeedType.following,
                                contentMode: _selectedContentMode,
                                categoryLabel: selectedCategory.label(context),
                              ),
                              ShortsFeedTab(
                                feedType: ShortsFeedType.live,
                                isActive: isLiveTab,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const PositionedDirectional(
                      top: 0,
                      start: 0,
                      end: 0,
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
