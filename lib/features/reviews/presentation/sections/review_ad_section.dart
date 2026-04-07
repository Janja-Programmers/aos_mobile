import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/reviews/controllers/review_controller.dart';
import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/features/reviews/navigation/reviews_routes.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/review_card.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/section_outlined_button.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ReviewAdSection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final visibleReviews = reviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews ($totalReviews)', style: context.h5),
            GestureDetector(
              onTap: () => ReviewNavigation.toAllReviews(context, adId),
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
        Column(
          children: [
            ...visibleReviews.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ReviewCard(
                      review: review,
                      onLike: () async {
                        final result = await ref
                            .read(reviewControllerProvider(adId).notifier)
                            .toggleReaction(
                              reviewId: review.id,
                              isLikeAction: true,
                            );

                        result.fold(
                          (e) => ShowSnack(context, e).error(),
                          (_) {},
                        );
                      },
                      onDislike: () async {
                        final result = await ref
                            .read(reviewControllerProvider(adId).notifier)
                            .toggleReaction(
                              reviewId: review.id,
                              isLikeAction: false,
                            );

                        result.fold(
                          (e) => ShowSnack(context, e).error(),
                          (_) {},
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        /// ALL Reviews
        if (totalReviews > 4) ...[
          const SizedBox(height: 8),
          SectionOutlineButton(
            text: "See all reviews",
            onTap: () => ReviewNavigation.toAllReviews(context, adId),
          ),
        ],
      ],
    );
  }
}
