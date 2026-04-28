import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:africaonlinestores/features/shorts/feeds/presentation/components/short_entity_grid_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/providers/feed_providers.dart';

class InspirationGrid extends ConsumerStatefulWidget {
  const InspirationGrid({super.key});

  @override
  ConsumerState<InspirationGrid> createState() => _InspirationGridState();
}

class _InspirationGridState extends ConsumerState<InspirationGrid> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inspirationGridControllerProvider.notifier).loadInitial();
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    final state = ref.read(inspirationGridControllerProvider);

    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return false;
    }

    final nearBottom =
        notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 240;

    if (!nearBottom) return false;

    ref.read(inspirationGridControllerProvider.notifier).loadMore();

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspirationGridControllerProvider);

    if (state.isLoading && state.shorts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.shorts.isEmpty) {
      return const Center(child: Text('No content found'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: MasonryGridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: state.shorts.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.shorts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final short = state.shorts[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ShortEntityGridCard(short: short, index: index),
            );
          },
        ),
      ),
    );
  }
}
