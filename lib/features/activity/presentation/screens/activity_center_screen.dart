import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/activity/application/activity_center_controller.dart';
import 'package:africaonlinestores/features/activity/data/activity_api.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ActivityCenterScreen extends ConsumerStatefulWidget {
  const ActivityCenterScreen({super.key});

  @override
  ConsumerState<ActivityCenterScreen> createState() =>
      _ActivityCenterScreenState();
}

class _ActivityCenterScreenState extends ConsumerState<ActivityCenterScreen> {
  final _scrollController = ScrollController();
  static const _groups = ['All', 'Shorts', 'Ads', 'Live', 'Social', 'Account'];

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
        title: Text('Activity Center', style: context.h5),
        actions: [
          IconButton(
            tooltip: 'Clear activity',
            onPressed: state.items.isEmpty
                ? null
                : controller.clearCurrentGroup,
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _groups.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final group = _groups[index];
                return ChoiceChip(
                  label: Text(group),
                  selected: state.group == group,
                  onSelected: (_) => controller.load(group: group),
                );
              },
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
                      cacheExtent: 700,
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
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
                            onHide: () => controller.hide(item.id),
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

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.onHide});

  final ActivityItem item;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = item.target.title ?? item.type.replaceAll('_', ' ');
    final subtitle = item.target.subtitle ?? item.group;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onHide(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: colors.red.withOpacity(.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.visibility_off_outlined, color: colors.red),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primary.withOpacity(.12),
              child: Icon(_iconForGroup(item.group), color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.pStrong,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.smallMuted,
                  ),
                ],
              ),
            ),
            if (item.count > 1)
              Text('x${item.count}', style: context.smallMuted),
          ],
        ),
      ),
    );
  }

  IconData _iconForGroup(String group) {
    switch (group) {
      case 'Shorts':
        return Icons.play_circle_outline_rounded;
      case 'Ads':
        return Icons.storefront_outlined;
      case 'Live':
        return Icons.sensors_rounded;
      case 'Social':
        return Icons.people_outline_rounded;
      case 'Account':
        return Icons.person_outline_rounded;
      default:
        return Icons.history_rounded;
    }
  }
}
