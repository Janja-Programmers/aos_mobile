import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/domain/aos_review.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/section_card.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:intl/intl.dart';

class AdReviewsSection extends StatelessWidget {
  const AdReviewsSection({
    super.key,
    required this.reviews,
    required this.totalReviews,
    required this.onSeeAll,
  });

  final List<AOSReview> reviews;
  final int totalReviews;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Product reviews',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final r = reviews[index];

                return _ReviewCard(
                  reviewer: r.reviewer,
                  rating: r.rating,
                  comment: r.comment,
                  date: r.creation,
                  likeCount: r.likeCount,
                  dislikeCount: r.dislikeCount,
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: onSeeAll,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.textPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text('See all reviews ($totalReviews)', style: context.p),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.date,
    required this.likeCount,
    required this.dislikeCount,
  });

  final String reviewer;
  final double rating;
  final String comment;
  final DateTime? date;
  final int likeCount;
  final int dislikeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final dateText = date != null
        ? DateFormat('MMM dd, yyyy').format(date!)
        : '';

    return Container(
      width: 270,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
        border: Border.all(color: colors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Stars + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating.round() ? Icons.star : Icons.star_border,
                    size: 16,
                    color: colors.warning,
                  ),
                ),
              ),
              Text(dateText, style: context.pMuted),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Text(
              comment,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: context.p,
            ),
          ),
          const SizedBox(height: 8),

          Text(reviewer, style: context.pMuted),
          const SizedBox(height: 6),

          Row(
            children: [
              Text('Helpful?', style: context.pMuted),
              const SizedBox(width: 10),
              const Icon(Icons.thumb_up_outlined, size: 16),
              const SizedBox(width: 6),
              Text('($likeCount)', style: context.pMuted),
              const SizedBox(width: 10),
              const Icon(Icons.thumb_down_outlined, size: 16),
              const SizedBox(width: 6),
              Text('($dislikeCount)', style: context.pMuted),
            ],
          ),
        ],
      ),
    );
  }
}
