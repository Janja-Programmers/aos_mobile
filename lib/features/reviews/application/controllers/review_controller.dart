import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/reviews/application/state/review_state.dart';
import 'package:africaonlinestores/features/reviews/data/review_api.dart';
import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/features/reviews/domain/review_sort.dart';
import 'package:africaonlinestores/features/reviews/domain/review_summary.dart';

final reviewControllerProvider =
    StateNotifierProvider.family<ReviewController, ReviewState, String>((
      ref,
      adId,
    ) {
      return ReviewController(ref, adId);
    });

final reviewListControllerProvider =
    StateNotifierProvider.family<ReviewController, ReviewState, String>(
      (ref, adId) =>
          ReviewController(ref, adId, syncPrimaryProviderAfterReaction: true),
    );

class ReviewController extends StateNotifier<ReviewState> {
  ReviewController(
    this.ref,
    this.adId, {
    this.syncPrimaryProviderAfterReaction = false,
  }) : super(const ReviewState()) {
    loadInitial();
  }

  final Ref ref;
  final String adId;
  final bool syncPrimaryProviderAfterReaction;
  final Set<String> _pendingReactionIds = <String>{};
  int _reviewsRequestId = 0;

  Future<void> loadInitial() async {
    await Future.wait([loadReviews(), loadReviewViewerState()]);
  }

  Future<void> loadReviewViewerState() async {
    state = state.copyWith(viewerStateLoading: true, clearError: true);

    final result = await ref
        .read(reviewApiProvider)
        .getReviewViewerState(ad: adId);

    result.fold(
      (failure) {
        state = state.copyWith(
          viewerStateLoading: false,
          error: failure.message,
        );
      },
      (viewerState) {
        state = state.copyWith(
          viewerStateLoading: false,
          viewerState: viewerState,
        );
      },
    );
  }

  Future<void> loadReviews() async {
    final requestId = ++_reviewsRequestId;
    final selectedSort = state.sort;
    final selectedRating = state.ratingFilter;

    state = state.copyWith(loading: true, clearError: true);

    final result = await ref
        .read(reviewApiProvider)
        .getAdReviews(adId: adId, sort: selectedSort, rating: selectedRating);

    if (requestId != _reviewsRequestId) return;

    result.fold(
      (failure) {
        state = state.copyWith(loading: false, error: failure.message);
      },
      (payload) {
        final data = payload['data'];
        final summaryJson = data is Map ? data['summary'] : null;
        final items = data is Map ? data['reviews'] : null;

        final summary = summaryJson is Map
            ? ReviewSummary.fromJson(Map<String, dynamic>.from(summaryJson))
            : null;

        final reviews = items is List
            ? items
                  .whereType<Map>()
                  .map(
                    (item) =>
                        AdReview.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList()
            : <AdReview>[];

        state = state.copyWith(
          loading: false,
          reviews: reviews,
          summary: summary,
        );
      },
    );
  }

  Future<void> setSort(ReviewSort sort) async {
    if (state.sort == sort) return;

    state = state.copyWith(sort: sort);
    await loadReviews();
  }

  Future<void> setRatingFilter(int? rating) async {
    if (rating != null && (rating < 1 || rating > 5)) return;
    if (state.ratingFilter == rating) return;

    state = state.copyWith(
      ratingFilter: rating,
      clearRatingFilter: rating == null,
    );

    await loadReviews();
  }

  Future<bool> submit({
    required double rating,
    required String title,
    required String comment,
    required List<String> images,
  }) async {
    state = state.copyWith(submitting: true, clearError: true);

    final res = await ref
        .read(reviewApiProvider)
        .createAdReview(
          ad: adId,
          rating: rating,
          title: title,
          comment: comment,
          images: images,
        );

    return res.fold(
      (failure) {
        state = state.copyWith(submitting: false, error: failure.message);
        return false;
      },
      (_) async {
        state = state.copyWith(submitting: false);
        await loadInitial();
        return true;
      },
    );
  }

  Future<Either<String, void>> toggleReaction({
    required String reviewId,
    required bool isLikeAction,
  }) async {
    if (!_pendingReactionIds.add(reviewId)) {
      return Either.right(null);
    }

    final reviewIndex = state.reviews.indexWhere((review) {
      return review.id == reviewId;
    });

    if (reviewIndex == -1) {
      _pendingReactionIds.remove(reviewId);
      return Either.left('Review not found.');
    }

    final previousReviews = List<AdReview>.from(state.reviews);
    final current = state.reviews[reviewIndex];

    var newLiked = current.isLiked;
    var newDisliked = current.isDisliked;
    var likeCount = current.likeCount;
    var dislikeCount = current.dislikeCount;
    final reaction = isLikeAction ? 'Like' : 'Dislike';

    if (isLikeAction) {
      if (current.isLiked) {
        newLiked = false;
        likeCount = (likeCount - 1).clamp(0, 999999).toInt();
      } else {
        newLiked = true;
        likeCount += 1;

        if (current.isDisliked) {
          newDisliked = false;
          dislikeCount = (dislikeCount - 1).clamp(0, 999999).toInt();
        }
      }
    } else {
      if (current.isDisliked) {
        newDisliked = false;
        dislikeCount = (dislikeCount - 1).clamp(0, 999999).toInt();
      } else {
        newDisliked = true;
        dislikeCount += 1;

        if (current.isLiked) {
          newLiked = false;
          likeCount = (likeCount - 1).clamp(0, 999999).toInt();
        }
      }
    }

    final updatedReviews = List<AdReview>.from(state.reviews);
    updatedReviews[reviewIndex] = current.copyWith(
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      isLiked: newLiked,
      isDisliked: newDisliked,
    );

    state = state.copyWith(reviews: updatedReviews);

    try {
      final result = await ref
          .read(reviewApiProvider)
          .toggleReview(reviewId: reviewId, reaction: reaction);

      return result.fold(
        (failure) {
          state = state.copyWith(reviews: previousReviews);
          return Either.left(failure.message);
        },
        (_) {
          if (syncPrimaryProviderAfterReaction) {
            ref.invalidate(reviewControllerProvider(adId));
          }
          return Either.right(null);
        },
      );
    } finally {
      _pendingReactionIds.remove(reviewId);
    }
  }
}
