import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/short_grid_card.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';

class FollowingShortsSection extends ConsumerStatefulWidget {
  const FollowingShortsSection({super.key});

  @override
  ConsumerState<FollowingShortsSection> createState() =>
      _FollowingShortsSectionState();
}

class _FollowingShortsSectionState
    extends ConsumerState<FollowingShortsSection> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final state = ref.read(shortGridControllerProvider);

      if (state.shorts.isEmpty && !state.isLoading) {
        ref.read(shortGridControllerProvider.notifier).loadInitial();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shortGridControllerProvider);
    final controller = ref.read(shortGridControllerProvider.notifier);

    if (state.isLoading && state.shorts.isEmpty) {
      return const SectionCard(
        title: 'From People You Follow',
        child: SizedBox(
          height: 230,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (state.shorts.isEmpty) {
      return SectionCard(
        title: 'From People You Follow',
        child: Text(
          'No shorts from people you follow yet',
          style: context.pMuted,
        ),
      );
    }

    return SectionCard(
      title: 'From People You Follow',
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.shorts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 0.60,
            ),
            itemBuilder: (context, index) {
              final short = state.shorts[index];

              return ShortGridCard(short: short, index: index);
            },
          ),

          if (state.isLoadingMore) ...[
            const SizedBox(height: 14),
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ],

          if (state.hasMore && !state.isLoadingMore) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: controller.loadMore,
              child: const Text('LOAD MORE'),
            ),
          ],
        ],
      ),
    );
  }
}
