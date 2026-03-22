import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/seller/domain/aos_seller.dart';
import 'package:africaonlinestores/features/seller/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/seller/presentation/widgets/seller_action_tabs.dart';
import 'package:africaonlinestores/features/seller/presentation/widgets/seller_response_badge.dart';

import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class SellerHeaderSection extends ConsumerWidget {
  const SellerHeaderSection({
    super.key,
    required this.seller,
    required this.sellerId,
  });

  final AOSSellerProfile seller;
  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final state = ref.watch(sellerStateProvider(sellerId));

    return SectionCard(
      child: Column(
        children: [
          /// Avatar
          AppCircularAvatar(
            name: seller.shopName,
            imageUrl: seller.avatar,
            radius: 24,
          ),

          const SizedBox(height: 12),

          /// Name + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(seller.shopName, style: context.h6),

              if (seller.isFollowing) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.blue.withOpacity(.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 12, color: colors.blue),
                      const SizedBox(width: 4),

                      Text('Verified', style: context.p),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          /// Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                title: '${seller.rating.toStringAsFixed(1)}/5',
                subtitle: 'Rating',
              ),
              _StatItem(
                title: '${seller.totalFollowers}',
                subtitle: 'Followers',
              ),
              _StatItem(title: seller.joined, subtitle: 'Joined'),
            ],
          ),

          const SizedBox(height: 14),

          /// Follow button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.followingLoading
                  ? null
                  : () async {
                      final wasFollowing = seller.isFollowing;

                      final error = await ref
                          .read(sellerStateProvider(sellerId).notifier)
                          .toggleFollow();

                      if (!context.mounted) return;

                      if (error != null) {
                        ShowSnack(context, error).error();
                      } else {
                        ShowSnack(
                          context,
                          wasFollowing ? "Unfollowed" : "Following",
                        ).success();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: seller.isFollowing
                    ? colors.surface
                    : colors.primary,
                foregroundColor: seller.isFollowing
                    ? colors.textPrimary
                    : colors.surface,
                side: seller.isFollowing
                    ? BorderSide(color: colors.border)
                    : null,
              ),
              child: Text(seller.isFollowing ? 'Following' : 'Follow'),
            ),
          ),
          const SizedBox(height: 12),

          const SellerResponseBadge(),
          const SizedBox(height: 12),

          const SellerActionTabs(),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: context.pStrong),
        const SizedBox(height: 2),
        Text(subtitle, style: context.pMuted),
      ],
    );
  }
}
