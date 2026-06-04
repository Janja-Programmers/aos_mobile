import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/reviews/application/controllers/review_controller.dart';
import 'package:africaonlinestores/features/reviews/application/navigation/reviews_routes.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/chip.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/review_card.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/summary_card.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.adId});

  final String adId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final state = ref.watch(reviewControllerProvider(adId));

    final totalReviews = state.reviews.length;
    final summary = state.summary;
    final reviews = state.reviews;

    return Scaffold(
      backgroundColor: colors.surface,

      /// APP BAR
      appBar: AppBar(
        title: Text('Reviews ($totalReviews)', style: context.h5),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// ⭐ SUMMARY CARD
                SummaryCard(
                  totalReviews: summary?.totalReviews ?? 0,
                  averageRating: summary?.averageRating ?? 0,
                  distribution: summary?.distribution ?? {},
                ),

                const SizedBox(height: 16),

                /// FILTERS
                const Row(
                  children: [
                    StatusChip(label: 'All Reviews', selected: true),
                    SizedBox(width: 10),
                    StatusChip(label: 'Newest'),
                    SizedBox(width: 10),
                    StatusChip(label: 'Filter', hasDropdown: true),
                  ],
                ),

                const SizedBox(height: 16),

                /// REVIEWS LIST
                ...reviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(child: ReviewCard(review: review)),
                  ),
                ),
              ],
            ),
          ),

          /// ✍️ BOTTOM BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () =>
                      ReviewNavigation.toCreateReview(context, adId),
                  text: 'Write a Review',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
