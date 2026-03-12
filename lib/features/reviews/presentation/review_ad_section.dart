import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/routing/app_routes.dart';

import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/features/reviews/presentation/review_card.dart';

class ReviewAdSection extends StatelessWidget {
  const ReviewAdSection({
    super.key,
    required this.reviews,
    required this.totalReviews,
    required this.adId,
  });

  final List<AdReview> reviews;
  final int totalReviews;
  final String adId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final visibleReviews = reviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews ($totalReviews)', style: context.h6),
            GestureDetector(
              onTap: () {
                context.pushNamed(
                  AppRoutes.nReview,
                  queryParameters: {'ad': adId},
                );
              },
              child: Row(
                children: [
                  Text(
                    'All Reviews',
                    style: context.p.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: colors.primary),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// REVIEW LIST
        ...visibleReviews.map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ReviewCard(review: review),
          ),
        ),
      ],
    );
  }
}
