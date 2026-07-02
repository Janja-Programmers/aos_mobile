import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/reviews/application/controllers/review_controller.dart';
import 'package:africaonlinestores/features/reviews/application/navigation/reviews_routes.dart';
import 'package:africaonlinestores/features/reviews/domain/review_sort.dart';
import 'package:africaonlinestores/features/reviews/presentation/sheets/review_rating_filter_sheet.dart';
import 'package:africaonlinestores/features/reviews/presentation/sheets/review_sort_sheet.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/chip.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/review_card.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/summary_card.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.adId});

  final String adId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(reviewListControllerProvider(adId));
    final controller = ref.read(reviewListControllerProvider(adId).notifier);
    final summary = state.summary;
    final totalReviews = summary?.totalReviews ?? state.reviews.length;

    Future<void> openSortSheet() async {
      final selected = await showReviewSortSheet(
        context,
        selectedSort: state.sort,
      );

      if (!context.mounted) return;

      if (selected != null) {
        await controller.setSort(selected);
      }
    }

    Future<void> openRatingFilterSheet() async {
      final selected = await showReviewRatingFilterSheet(
        context,
        selectedRating: state.ratingFilter,
      );

      if (!context.mounted) return;

      if (selected != null) {
        await controller.setRatingFilter(selected);
      }
    }

    Future<void> react({
      required String reviewId,
      required bool isLikeAction,
    }) async {
      final result = await controller.toggleReaction(
        reviewId: reviewId,
        isLikeAction: isLikeAction,
      );

      if (!context.mounted) return;

      result.fold((message) => ShowSnack(context, message).error(), (_) {});
    }

    Future<void> openCreateReview() async {
      final created = await ReviewNavigation.toCreateReview(context, adId);

      if (!context.mounted) return;

      if (created ?? false) {
        ref.invalidate(reviewControllerProvider(adId));
        await controller.loadInitial();
      }
    }

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text('Reviews ($totalReviews)', style: context.h5),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadReviews,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  SummaryCard(
                    totalReviews: summary?.totalReviews ?? 0,
                    averageRating: summary?.averageRating ?? 0,
                    distribution: summary?.distribution ?? {},
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatusChip(
                          label: 'All Reviews',
                          selected: !state.hasRatingFilter,
                          onTap: () => controller.setRatingFilter(null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatusChip(
                          label: state.sort.chipLabel,
                          selected: state.sort != ReviewSort.newest,
                          hasDropdown: true,
                          onTap: openSortSheet,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatusChip(
                          label: state.ratingFilter == null
                              ? 'Filter'
                              : '${state.ratingFilter} Star',
                          selected: state.hasRatingFilter,
                          hasDropdown: true,
                          onTap: openRatingFilterSheet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.loading && state.reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.hasError && state.reviews.isEmpty)
                    _ReviewErrorState(
                      message: state.error!,
                      onRetry: controller.loadReviews,
                    )
                  else if (state.reviews.isEmpty)
                    _ReviewEmptyState(
                      hasRatingFilter: state.hasRatingFilter,
                      onClearFilter: () => controller.setRatingFilter(null),
                    )
                  else ...[
                    if (state.loading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    ...state.reviews.map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SectionCard(
                          child: ReviewCard(
                            review: review,
                            onLike: () =>
                                react(reviewId: review.id, isLikeAction: true),
                            onDislike: () =>
                                react(reviewId: review.id, isLikeAction: false),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: openCreateReview,
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

class _ReviewErrorState extends StatelessWidget {
  const _ReviewErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: context.pMuted),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class _ReviewEmptyState extends StatelessWidget {
  const _ReviewEmptyState({
    required this.hasRatingFilter,
    required this.onClearFilter,
  });

  final bool hasRatingFilter;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 40,
            color: context.appColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            hasRatingFilter
                ? 'No reviews match this rating.'
                : 'No reviews yet.',
            style: context.pMuted,
          ),
          if (hasRatingFilter) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onClearFilter,
              child: const Text('Show all reviews'),
            ),
          ],
        ],
      ),
    );
  }
}
