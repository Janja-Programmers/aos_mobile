import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/activity/application/activity_center_controller.dart';
import 'package:africaonlinestores/features/activity/data/activity_api.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityCenterScreen extends ConsumerStatefulWidget {
  const ActivityCenterScreen({super.key});

  @override
  ConsumerState<ActivityCenterScreen> createState() =>
      _ActivityCenterScreenState();
}

class _ActivityCenterScreenState extends ConsumerState<ActivityCenterScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _openingTargets = <String>{};

  static const List<_ActivityFilter> _filters = <_ActivityFilter>[
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(activityCenterControllerProvider.notifier).load());
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 360) {
      unawaited(ref.read(activityCenterControllerProvider.notifier).loadMore());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _openActivity(ActivityItem item) async {
    final String routeType = item.target.routeType?.trim().toLowerCase() ?? '';
    final String routeId =
        item.target.routeId?.trim() ?? item.target.name?.trim() ?? '';

    if (routeType == 'user_search') {
      SocialNavigation.toUserSearch(context);
      return;
    }

    final String? safeRouteId = _safeIdentifier(routeId);
    if (safeRouteId == null) return;
    final String openingKey = '$routeType:$safeRouteId';
    if (!_openingTargets.add(openingKey)) return;

    try {
      switch (routeType) {
        case 'ad':
          // Activity is historical. An ad that was valid when recorded may no
          // longer satisfy the public `get_ad` contract. Verify before routing
          // so the user never lands on a dead/infinite-loading detail screen.
          final result = await ref
              .read(adsApiProvider)
              .getAd(adId: safeRouteId);
          if (!mounted) return;
          if (result.isLeft) {
            ShowSnack(context, 'This listing is no longer available.').info();
            return;
          }
          AdNavigation.toDetail(context, safeRouteId);
          return;
        case 'short':
          ShortsNavigation.toShortDetailById(context, shortId: safeRouteId);
          return;
        case 'live':
          LiveNavigation.toLiveRoom(context, liveId: safeRouteId);
          return;
        case 'profile':
          SocialNavigation.toProfileScreen(
            context,
            user: safeRouteId,
            displayName: item.target.title,
            avatar: item.target.image,
          );
          return;
      }
    } finally {
      _openingTargets.remove(openingKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ActivityCenterState state = ref.watch(
      activityCenterControllerProvider,
    );
    final ActivityCenterController controller = ref.read(
      activityCenterControllerProvider.notifier,
    );

    ref.listen<String?>(
      activityCenterControllerProvider.select(
        (ActivityCenterState value) => value.error,
      ),
      (String? previous, String? next) {
        if (next != null &&
            next != previous &&
            mounted &&
            state.items.isNotEmpty) {
          ShowSnack(context, next).error();
        }
      },
    );

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
        actions: <Widget>[
          TextButton(
            onPressed: !state.hasLoaded || state.items.isEmpty
                ? null
                : () => unawaited(_confirmAndClear(state, controller)),
            child: Text(
              'Clear',
              style: context.pStrong.copyWith(color: colors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final _ActivityFilter filter = _filters[index];
                  final bool selected = state.group == filter.queryGroup;
                  return _ActivityFilterChip(
                    label: filter.label,
                    selected: selected,
                    onTap: () =>
                        unawaited(controller.load(group: filter.queryGroup)),
                  );
                },
              ),
            ),
            if (state.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'Recent activity',
                    style: context.pStrong.copyWith(color: colors.textMuted),
                  ),
                ),
              ),
            Expanded(
              child: _buildBody(state: state, controller: controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required ActivityCenterState state,
    required ActivityCenterController controller,
  }) {
    final colors = context.appColors;
    if (state.loading && !state.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && !state.hasLoaded) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 160),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                Text(state.error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      unawaited(controller.load(group: state.group)),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.load(group: state.group),
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            const SizedBox(height: 180),
            Icon(Icons.history_rounded, size: 56, color: colors.textMuted),
            const SizedBox(height: 12),
            Center(child: Text('No activity yet', style: context.pStrong)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.load(group: state.group),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          if (index == state.items.length) {
            if (state.loadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state.hasMore && state.error != null) {
              return Center(
                child: TextButton(
                  onPressed: () => unawaited(controller.loadMore()),
                  child: const Text('Retry'),
                ),
              );
            }
            return const SizedBox(height: 1);
          }

          final ActivityItem item = state.items[index];
          return RepaintBoundary(
            key: ValueKey<String>(item.id),
            child: Dismissible(
              key: ValueKey<String>('activity:${item.id}'),
              direction: DismissDirection.endToStart,
              dismissThresholds: const <DismissDirection, double>{
                DismissDirection.endToStart: .35,
              },
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.visibility_off_outlined,
                  color: colors.surface,
                ),
              ),
              confirmDismiss: (_) async {
                await HapticFeedback.selectionClick();
                return true;
              },
              onDismissed: (_) => unawaited(controller.hide(item.id)),
              child: _ActivityTile(
                item: item,
                onTap: () => unawaited(_openActivity(item)),
                onLongPress: () => _showHideSheet(item, controller),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmAndClear(
    ActivityCenterState state,
    ActivityCenterController controller,
  ) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Clear activity?'),
            content: Text(
              state.group == 'All'
                  ? 'Hide all items from your Activity Center?'
                  : 'Hide all ${state.group} activity items?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && mounted) await controller.clearCurrentGroup();
  }

  void _showHideSheet(ActivityItem item, ActivityCenterController controller) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (BuildContext sheetContext) => SafeArea(
          top: false,
          child: ListTile(
            leading: const Icon(Icons.visibility_off_outlined),
            title: const Text('Hide from activity'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(controller.hide(item.id));
            },
          ),
        ),
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
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: selected ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: context.pStrong.copyWith(
              color: selected ? colors.white : colors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final ActivityItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final String title = item.target.title ?? item.type.replaceAll('_', ' ');
    final String subtitle = item.target.subtitle ?? item.group;
    final String? imageUrl = buildFileUrl(item.target.image);
    final bool hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final Color accent = _accentColor(context, item.group);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.black.withValues(alpha: .03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            _activityLabel(item),
                            style: context.small.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.pStrong.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.smallMuted,
                      ),
                      if (item.count > 1) ...<Widget>[
                        const SizedBox(height: 3),
                        Text('×${item.count}', style: context.smallMuted),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _activityLabel(ActivityItem item) {
    final String type = item.type.trim().toLowerCase();
    return switch (type) {
      'short_watch' => 'Watched',
      'short_like' => 'Liked',
      'short_repost' => 'Reposted',
      'short_comment' => 'Commented',
      'short_report' => 'Reported',
      'ad_view' => 'Viewed',
      'ad_wishlist' => 'Saved',
      'ad_posted' => 'Posted',
      'ad_report' => 'Reported',
      'live_join' || 'live_host' => 'Live',
      'live_comment' => 'Commented',
      'user_search' => 'Searched',
      'user_follow' => 'Followed',
      'user_block' => 'Blocked',
      'user_report' => 'Reported',
      _ => _humanize(type, fallback: item.group),
    };
  }

  static String _humanize(String value, {required String fallback}) {
    final String clean = value.replaceAll('_', ' ').trim();
    if (clean.isEmpty) return fallback;
    return clean[0].toUpperCase() + clean.substring(1);
  }

  static String _relativeTime(DateTime? date) {
    if (date == null) return '';
    final Duration diff = DateTime.now().difference(date.toLocal());
    if (diff.isNegative || diff.inMinutes < 1) return 'now';
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  static IconData _iconForGroup(String group) {
    return switch (group) {
      'Shorts' => Icons.play_circle_outline_rounded,
      'Ads' => Icons.storefront_outlined,
      'Live' => Icons.sensors_rounded,
      'Search' => Icons.search_rounded,
      'Social' => Icons.people_outline_rounded,
      'Account' => Icons.person_outline_rounded,
      'Reviews' => Icons.reviews_outlined,
      _ => Icons.history_rounded,
    };
  }

  static Color _accentColor(BuildContext context, String group) {
    final colors = context.appColors;
    return switch (group) {
      'Shorts' => colors.purple,
      'Ads' => colors.primary,
      'Live' => colors.red,
      'Search' => colors.blue,
      'Social' => colors.success,
      _ => colors.primary,
    };
  }
}

String? _safeIdentifier(String value) {
  final String clean = value.trim();
  if (clean.isEmpty || clean.length > 200) return null;
  return RegExp(r'^[A-Za-z0-9._@+:-]+$').hasMatch(clean) ? clean : null;
}
