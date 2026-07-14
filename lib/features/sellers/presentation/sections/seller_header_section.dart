import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/seller_banner_header.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/seller_response_badge.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          SellerBannerHeader(seller: seller),

          const SizedBox(height: 14),

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
                const VerifiedBadge(),
              ],
            ],
          ),

          if (seller.businessCategory != null) ...[
            const SizedBox(height: 6),
            Text(
              seller.businessCategory!,
              style: context.pMuted,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colors.surface,
              border: Border.all(color: colors.border.withValues(alpha: .6)),
            ),
            child: Row(
              children: [
                _StatItem(
                  icon: Icons.star_rounded,
                  title: seller.ratingLabel,
                  subtitle: 'Rating',
                ),
                _divider(colors),
                _StatItem(
                  icon: Icons.group_outlined,
                  title: seller.followersLabel,
                  subtitle: 'Followers',
                ),
                _divider(colors),
                _StatItem(
                  icon: Icons.calendar_today_outlined,
                  title: seller.joined.trim().isEmpty ? '—' : seller.joined,
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

          if (!seller.isSelf && seller.canFollow)
            _SellerFollowButton(
              seller: seller,
              sellerId: sellerId,
              isFollowing: state.isFollowing,
              loading: state.followingLoading,
            ),
        ],
      ),
    );
  }
}

class _SellerFollowButton extends ConsumerWidget {
  const _SellerFollowButton({
    required this.seller,
    required this.sellerId,
    required this.isFollowing,
    required this.loading,
  });

  final AOSSellerProfile seller;
  final String sellerId;
  final bool? isFollowing;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    if (isFollowing == null) return const SizedBox.shrink();

    final label = _followLabel(seller, effectiveFollowing: isFollowing!);
    final active = label == 'Following';

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: loading
            ? null
            : () async {
                final wasFollowing = active;

                final error = await ref
                    .read(sellerStateProvider(sellerId).notifier)
                    .toggleFollow();

                if (!context.mounted) return;

                if (error != null) {
                  ShowSnack(context, error).error();
                } else {
                  ShowSnack(
                    context,
                    wasFollowing ? 'Unfollowed' : 'Following',
                  ).success();
                }
              },
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: active ? colors.textPrimary : colors.white,
                ),
              )
            : Icon(
                active ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
                size: 18,
              ),
        label: Text(loading ? 'Please wait...' : label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: active ? colors.surface : colors.primary,
          foregroundColor: active ? colors.textPrimary : colors.white,
          disabledBackgroundColor: active ? colors.surface : colors.primary,
          disabledForegroundColor: active ? colors.textPrimary : colors.white,
          side: BorderSide(color: active ? colors.border : colors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static String _followLabel(
    AOSSellerProfile seller, {
    required bool effectiveFollowing,
  }) {
    final status = seller.relationshipStatus.trim().toLowerCase();
    final raw = seller.actionLabel.trim().toLowerCase();
    final friend =
        seller.isFriend || (seller.isFollowedBy && effectiveFollowing);

    if (friend ||
        effectiveFollowing ||
        status == 'friends' ||
        status == 'following') {
      return 'Following';
    }

    if (seller.isFollowedBy ||
        status == 'followed_by' ||
        raw == 'follow back') {
      return 'Follow back';
    }

    return 'Follow';
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
              Flexible(
                child: Text(
                  title,
                  style: context.pStrong,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
