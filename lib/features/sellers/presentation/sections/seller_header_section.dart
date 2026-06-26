import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/seller_response_badge.dart';

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
    final isFollowing = state.isFollowing ?? false;

    return SectionCard(
      child: Column(
        children: [
          const SizedBox(height: 10),

          AppCircularAvatar(name: seller.displayName, imageUrl: seller.avatar),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  seller.displayName,
                  style: context.h5,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (seller.isVerified) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.blue.withOpacity(.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 13, color: colors.blue),
                      const SizedBox(width: 3),
                      Text(
                        'Verified',
                        style: context.p.copyWith(
                          color: colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colors.surface,
              border: Border.all(color: colors.border.withOpacity(.6)),
            ),
            child: Row(
              children: [
                _StatItem(
                  icon: Icons.star,
                  title: '${seller.rating.toStringAsFixed(1)} / 5',
                  subtitle: 'Rating',
                ),
                _divider(colors),
                _StatItem(
                  icon: Icons.group_outlined,
                  title: _formatCount(seller.totalFollowers),
                  subtitle: 'Followers',
                ),
                _divider(colors),
                _StatItem(
                  icon: Icons.calendar_today_outlined,
                  title: seller.joined,
                  subtitle: 'Joined',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SellerResponseBadge(
            responseTimeDisplay: seller.responseTimeDisplay,
            responseRateDisplay: seller.responseRateDisplay,
          ),

          if (seller.responseTimeDisplay != null ||
              seller.responseRateDisplay != null)
            const SizedBox(height: 18)
          else
            const SizedBox(height: 4),

          if (!seller.isSelf)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: state.followingLoading
                    ? null
                    : () async {
                        final wasFollowing = isFollowing;

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
                icon: state.followingLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isFollowing ? Icons.check : Icons.person_add_alt_1,
                        size: 18,
                      ),
                label: Text(
                  state.followingLoading
                      ? 'Please wait...'
                      : isFollowing
                      ? 'Following'
                      : 'Follow',
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: isFollowing
                      ? colors.surface
                      : colors.primary,
                  foregroundColor: isFollowing
                      ? colors.textPrimary
                      : colors.white,
                  disabledBackgroundColor: isFollowing
                      ? colors.surface
                      : colors.primary,
                  disabledForegroundColor: isFollowing
                      ? colors.textPrimary
                      : colors.white,
                  side: BorderSide(
                    color: isFollowing ? colors.border : colors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: colors.textMuted),
              const SizedBox(width: 4),
              Text(title, style: context.pStrong),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: context.pMuted),
        ],
      ),
    );
  }
}

Widget _divider(AppColorTokens colors) {
  return Container(width: 1, height: 34, color: colors.border);
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toString();
}
