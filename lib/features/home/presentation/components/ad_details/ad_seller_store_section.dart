import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/account/shared/utils/avator_image.dart';
import 'package:africaonlinestores/features/reviews/application/state/review_state.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:flutter/material.dart';

class AdSellerInfoSection extends StatelessWidget {
  const AdSellerInfoSection({
    super.key,
    required this.displayName,
    required this.avatar,
    required this.rating,
    required this.totalReviews,
    required this.totalFollowers,
    required this.totalAds,
    required this.joined,
    required this.isFollowing,
    this.isVerified = false,
    required this.reviewState,
    required this.onVisitStore,
    required this.onReview,
    required this.onReport,
    required this.onPostSimilar,
  });

  final String displayName;
  final String? avatar;
  final double rating;
  final int totalReviews;
  final int totalFollowers;
  final int totalAds;
  final String joined;
  final bool isFollowing;
  final bool isVerified;
  final ReviewState reviewState;
  final VoidCallback onVisitStore;
  final VoidCallback onReview;
  final VoidCallback onReport;
  final VoidCallback onPostSimilar;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final safeDisplayName = displayName.trim().isEmpty
        ? 'Seller'
        : displayName.trim();
    final image = resolveAvatarImage(avatar, AppConfig.normalizedBaseUrl);

    return SectionCard(
      title: 'Seller Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.border,
                backgroundImage: image,
                onBackgroundImageError: image == null ? null : (_, _) {},
                child: image == null
                    ? Text(
                        safeDisplayName.characters.first.toUpperCase(),
                        style: context.h2,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            safeDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.pStrong,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          const VerifiedBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: colors.warning),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1), style: context.pStrong),
                        const SizedBox(width: 6),
                        Text('·', style: context.pMuted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '$totalFollowers followers',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.pMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_SellerAction>(
                tooltip: 'More listing actions',
                onSelected: (action) {
                  switch (action) {
                    case _SellerAction.postSimilar:
                      onPostSimilar();
                      return;
                    case _SellerAction.report:
                      onReport();
                      return;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _SellerAction.postSimilar,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.add_box_outlined),
                      title: Text('Post similar ad'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _SellerAction.report,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.flag_outlined),
                      title: Text('Report listing'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _Metric(
                  value: totalReviews.toString(),
                  label: 'Reviews',
                  icon: Icons.rate_review_outlined,
                ),
                Container(width: 1, height: 54, color: colors.border),
                _Metric(
                  value: joined.trim().isEmpty ? '—' : joined,
                  label: 'Joined',
                  icon: Icons.calendar_month_outlined,
                ),
                Container(width: 1, height: 54, color: colors.border),
                _Metric(
                  value: totalAds.toString(),
                  label: 'Listings',
                  icon: Icons.inventory_2_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onVisitStore,
              child: const Text('Visit Seller Store'),
            ),
          ),
          if (reviewState.canReview) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Review Product'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _SellerAction { postSimilar, report }

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.pStrong,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: colors.textMuted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.small.copyWith(color: colors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
