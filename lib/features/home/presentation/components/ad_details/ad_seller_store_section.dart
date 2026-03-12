import 'package:africaonlinestores/features/account/shared/utils/avator_image.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/section_card.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class AdSellerInfoSection extends StatelessWidget {
  const AdSellerInfoSection({
    super.key,
    required this.shopName,
    required this.avatar,
    required this.rating,
    required this.totalReviews,
    required this.totalFollowers,
    required this.totalAds,
    required this.joined,
    required this.isFollowing,
    required this.onVisitStore,
    required this.onReview,
    required this.onReport,
    required this.onPostSimilar,
  });

  final String shopName;
  final String? avatar;
  final double rating;
  final int totalReviews;
  final int totalFollowers;
  final int totalAds;
  final String joined;
  final bool isFollowing;

  final VoidCallback onVisitStore;
  final VoidCallback onReview;
  final VoidCallback onReport;
  final VoidCallback onPostSimilar;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ImageProvider? img = resolveAvatarImage(
      avatar,
      "Https://aos-staging.m.frappe.cloud",
    );
    final initial = shopName.characters.first;

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
                        Text(shopName, style: context.pStrong),
                        const SizedBox(width: 8),
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

          /// Stats Row
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

          /// Visit Store Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onVisitStore,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary.withOpacity(0.12),
                foregroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Visit Seller Store'),
            ),
          ),

          const SizedBox(height: 12),

          /// Action Buttons
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
                    style: context.p.copyWith(color: colors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                    style: context.p.copyWith(color: colors.primary),
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
