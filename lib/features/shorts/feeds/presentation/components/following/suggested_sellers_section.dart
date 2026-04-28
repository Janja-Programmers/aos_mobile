import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/following/following_section_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/following/following_sellers_card.dart';

import 'package:africaonlinestores/shared/components/cards/section_card.dart';

class SuggestedSellersSection extends ConsumerStatefulWidget {
  const SuggestedSellersSection({super.key});

  @override
  ConsumerState<SuggestedSellersSection> createState() =>
      _SuggestedSellersSectionState();
}

class _SuggestedSellersSectionState
    extends ConsumerState<SuggestedSellersSection> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(followingSectionControllerProvider.notifier).loadSellers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followingSectionControllerProvider);
    final controller = ref.read(followingSectionControllerProvider.notifier);

    if (state.isLoading) {
      return const SectionCard(
        title: 'Suggested for You',
        child: SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (state.error != null) {
      return SectionCard(
        title: 'Suggested for You',
        child: Center(child: Text(state.error!, style: context.pMuted)),
      );
    }

    if (state.sellers.isEmpty) {
      return SectionCard(
        title: 'Suggested for You',
        child: Center(
          child: Text('No seller suggestions found', style: context.pMuted),
        ),
      );
    }

    return SectionCard(
      title: 'Suggested for You',
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.sellers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final seller = state.sellers[index];

                return FollowingSellerCard(
                  seller: seller,
                  onFollowTap: () => controller.toggleFollow(seller),
                  onDismiss: () => controller.dismissSeller(seller.sellerId),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
