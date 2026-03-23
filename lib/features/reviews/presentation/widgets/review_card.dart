import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/reviews/domain/review_model.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    this.onLike,
    this.onDislike,
  });

  final AdReview review;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final avatarLetter = review.reviewer.isNotEmpty
        ? review.reviewer[0].toUpperCase()
        : '?';

    final formattedDate = review.creation != null
        ? '${_month(review.creation!.month)} ${review.creation!.day}, ${review.creation!.year}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.primaryRedSoft,
              child: Text(
                avatarLetter,
                style: context.pStrong.copyWith(color: colors.surface),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.reviewer, style: context.pStrong),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StarRating(rating: review.rating.toInt()),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: context.p.copyWith(color: colors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(review.comment, style: context.p),

        const SizedBox(height: 14),

        /// FOOTER
        Row(
          children: [
            Text(
              'Helpful?',
              style: context.p.copyWith(color: colors.textMuted),
            ),

            const SizedBox(width: 10),

            /// 👍 LIKE
            GestureDetector(
              onTap: onLike,
              child: Row(
                children: [
                  Icon(
                    review.isLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_alt_outlined,
                    size: 16,
                    color: review.isLiked ? colors.primary : colors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${review.likeCount})',
                    style: context.p.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// 👎 DISLIKE
            GestureDetector(
              onTap: onDislike,
              child: Row(
                children: [
                  Icon(
                    review.isDisliked
                        ? Icons.thumb_down
                        : Icons.thumb_down_alt_outlined,
                    size: 16,
                    color: review.isDisliked
                        ? colors.primary
                        : colors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${review.dislikeCount})',
                    style: context.p.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
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
          color: i < rating ? colors.amber : colors.border,
        ),
      ),
    );
  }
}
