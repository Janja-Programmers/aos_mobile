import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/features/account/shared/utils/avator_image.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

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

  final VoidCallback onVisitStore;
  final VoidCallback onReview;
  final VoidCallback onReport;
  final VoidCallback onPostSimilar;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final safeDisplayName = displayName.trim().isNotEmpty
        ? displayName.trim()
        : 'Seller';

    final ImageProvider? img = resolveAvatarImage(
      avatar,
      AppConfig.normalizedBaseUrl,
    );

    final initial = safeDisplayName.characters.first.toUpperCase();

    return SectionCard(
      title: 'Seller Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.border,
                backgroundImage: img,
                onBackgroundImageError: img != null ? (_, _) {} : null,
                child: img == null ? Text(initial, style: context.h2) : null,
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
                            style: context.pStrong,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: colors.success.withOpacity(0.08),
                            ),
                            child: Text(
                              'Verified',
                              style: context.p.copyWith(
                                color: colors.success,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: colors.warning),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1), style: context.pStrong),
                        const SizedBox(width: 6),
                        Text('·', style: context.pStrong),
                        const SizedBox(width: 6),
                        Text(
                          '$totalFollowers followers',
                          style: context.pMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _info(
                  context,
                  Icons.rate_review_outlined,
                  'Reviews',
                  totalReviews.toString(),
                ),
                _divider(colors.black.withOpacity(0.5)),
                _info(context, Icons.calendar_month, 'Joined', joined),
                _divider(colors.black.withOpacity(0.5)),
                _info(
                  context,
                  Icons.inventory_2_outlined,
                  'Listings',
                  totalAds.toString(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onVisitStore,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Visit Seller Store',
                style: context.p.copyWith(color: colors.primary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReview,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Review Product',
                    style: context.p.copyWith(
                      color: colors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReport,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Report Product',
                    style: context.p.copyWith(
                      color: colors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPostSimilar,
              child: const Text('Post an Ad like this'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).hintColor),
          const SizedBox(height: 6),
          Text(label, style: context.pMuted),
          const SizedBox(height: 4),
          Text(value, style: context.pStrong),
        ],
      ),
    );
  }

  Widget _divider(Color color) {
    return Container(height: 40, width: 1, color: color);
  }
}
