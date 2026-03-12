import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/reviews/domain/review_model.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final AdReview review;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final avatarLetter = review.id.isNotEmpty
        ? review.id[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// USER HEADER
          Row(
            children: [
              /// AVATAR
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary.withOpacity(0.15),
                child: Text(
                  avatarLetter,
                  style: context.pStrong.copyWith(color: colors.primary),
                ),
              ),

              const SizedBox(width: 10),

              /// NAME + DATE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("review.userName", style: context.pStrong),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        /// STARS
                        const _StarRating(rating: 5),

                        const SizedBox(width: 8),

                        Text(
                          "review.created",
                          style: context.p.copyWith(color: colors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// COMMENT
          Text(review.comment, style: context.p),

          const SizedBox(height: 12),

          /// FOOTER
          Row(
            children: [
              Text(
                'Helpful',
                style: context.p.copyWith(color: colors.textMuted),
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.thumb_up_alt_outlined,
                size: 16,
                color: colors.textMuted,
              ),

              const SizedBox(width: 4),

              Text(
                '(review.helpful',
                style: context.p.copyWith(color: colors.textMuted),
              ),

              const SizedBox(width: 12),

              Icon(
                Icons.thumb_down_alt_outlined,
                size: 16,
                color: colors.textMuted,
              ),

              const SizedBox(width: 4),

              Text(
                'review.notHelpful',
                style: context.p.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          Icons.star,
          size: 14,
          color: i < rating ? Colors.amber : colors.border,
        ),
      ),
    );
  }
}
