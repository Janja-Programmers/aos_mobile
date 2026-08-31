import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/activity/application/activity_center_controller.dart';
import 'package:africaonlinestores/features/activity/data/activity_api.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityCenterScreen extends ConsumerStatefulWidget {
  const ActivityCenterScreen({super.key});

  @override
  ConsumerState<ActivityCenterScreen> createState() =>
      _ActivityCenterScreenState();
}

class _ActivityCenterScreenState extends ConsumerState<ActivityCenterScreen> {
  final _scrollController = ScrollController();

  static const _filters = <_ActivityFilter>[
    _ActivityFilter(label: 'All'),
    _ActivityFilter(label: 'Products', group: 'Ads'),
    _ActivityFilter(label: 'Shorts', group: 'Shorts'),
    _ActivityFilter(label: 'Searches', group: 'Search'),
    _ActivityFilter(label: 'Live', group: 'Live'),
    _ActivityFilter(label: 'Social', group: 'Social'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(activityCenterControllerProvider.notifier).load(),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final metrics = _scrollController.position;
    if (metrics.extentAfter < 360) {
      ref.read(activityCenterControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _openActivity(ActivityItem item) {
    final routeType = item.target.routeType?.trim().toLowerCase() ?? '';
    final routeId =
        item.target.routeId?.trim() ?? item.target.name?.trim() ?? '';

    if (routeType == 'user_search') {
      SocialNavigation.toUserSearch(context);
      return;
    }

    if (routeId.isEmpty) return;

    switch (routeType) {
      case 'ad':
        AdNavigation.toDetail(context, routeId);
        return;
      case 'short':
        ShortsNavigation.toShortDetailById(context, shortId: routeId);
        return;
      case 'live':
        LiveNavigation.toLiveRoom(context, liveId: routeId);
        return;
      case 'profile':
        SocialNavigation.toProfileScreen(
          context,
          user: routeId,
          displayName: item.target.title,
          avatar: item.target.image,
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(activityCenterControllerProvider);
    final controller = ref.read(activityCenterControllerProvider.notifier);

    ref.listen(activityCenterControllerProvider.select((s) => s.error), (
      prev,
      next,
    ) {
      if (next != null && next != prev && mounted) {
        ShowSnack(context, next).error();
      }
    });

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Activity Center',
          style: context.h5.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: state.items.isEmpty
                ? null
                : controller.clearCurrentGroup,
            child: Text(
              'Clear',
              style: context.pStrong.copyWith(color: colors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final filter = _filters[index];
                final selected = state.group == filter.queryGroup;
                return _ActivityFilterChip(
                  label: filter.label,
                  selected: selected,
                  onTap: () => controller.load(group: filter.queryGroup),
                );
              },
            ),
          ),
          if (state.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'This Week',
                  style: context.pStrong.copyWith(color: colors.textMuted),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.load(group: state.group),
              child: state.loading && state.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.items.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 180),
                        Icon(
                          Icons.history_rounded,
                          size: 56,
                          color: colors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'No activity yet',
                            style: context.pStrong,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                      itemCount:
                          state.items.length + (state.loadingMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        if (index >= state.items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final item = state.items[index];
                        return RepaintBoundary(
                          key: ValueKey(item.id),
                          child: _ActivityTile(
                            item: item,
                            onTap: () => _openActivity(item),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityFilter {
  const _ActivityFilter({required this.label, this.group});

  final String label;
  final String? group;

  String get queryGroup => group ?? 'All';
}

class _ActivityFilterChip extends StatelessWidget {
  const _ActivityFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(
          label,
          style: context.pStrong.copyWith(
            color: selected ? colors.white : colors.textPrimary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.onTap});

  final ActivityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = item.target.title ?? item.type.replaceAll('_', ' ');
    final subtitle = item.target.subtitle ?? item.group;
    final imageUrl = buildFileUrl(item.target.image);
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final accent = _accentColor(context, item.group);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.black.withValues(alpha: .03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 54,
                  height: 54,
                  color: accent.withValues(alpha: .12),
                  child: hasImage
                      ? AppNetworkImage(
                          url: imageUrl,
                          width: 54,
                          height: 54,
                          errorBuilder: (_, _, _) =>
                              Icon(_iconForGroup(item.group), color: accent),
                        )
                      : Icon(_iconForGroup(item.group), color: accent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _activityLabel(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.small.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          _relativeTime(
                            item.lastOccurrenceAt ?? item.occurredAt,
                          ),
                          style: context.smallMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.pStrong.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.smallMuted,
                    ),
                  ],
                ),
              ),
              if (item.count > 1) ...[
                const SizedBox(width: 6),
                Text('x${item.count}', style: context.smallMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _activityLabel(ActivityItem item) {
    final type = item.type.trim().toLowerCase();
    switch (type) {
      case 'short_watch':
        return 'Watched';
      case 'short_like':
        return 'Liked';
      case 'short_repost':
        return 'Reposted';
      case 'ad_view':
        return 'Viewed';
      case 'ad_wishlist':
        return 'Saved';
      case 'live_join':
      case 'live_host':
        return 'Live';
      case 'user_search':
        return 'Searched';
      case 'user_follow':
        return 'Followed';
      default:
        final clean = type.replaceAll('_', ' ').trim();
        if (clean.isEmpty) return item.group;
        return clean[0].toUpperCase() + clean.substring(1);
    }
  }

  static String _relativeTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'now';
  }

  static IconData _iconForGroup(String group) {
    switch (group) {
      case 'Shorts':
        return Icons.play_circle_outline_rounded;
      case 'Ads':
        return Icons.storefront_outlined;
      case 'Live':
        return Icons.sensors_rounded;
      case 'Search':
        return Icons.search_rounded;
      case 'Social':
        return Icons.people_outline_rounded;
      case 'Account':
        return Icons.person_outline_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  static Color _accentColor(BuildContext context, String group) {
    final colors = context.appColors;
    switch (group) {
      case 'Shorts':
        return colors.purple;
      case 'Ads':
        return colors.primary;
      case 'Live':
        return colors.red;
      case 'Search':
        return colors.blue;
      case 'Social':
        return colors.success;
      default:
        return colors.primary;
    }
  }
}
