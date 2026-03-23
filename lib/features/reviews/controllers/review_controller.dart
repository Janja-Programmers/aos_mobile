import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/reviews/controllers/review_state.dart';
import 'package:africaonlinestores/features/reviews/data/review_api.dart';
import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/features/reviews/domain/review_summary.dart';

final reviewControllerProvider =
    StateNotifierProvider.family<ReviewController, ReviewState, String>((
      ref,
      adId,
    ) {
      return ReviewController(ref, adId);
    });

class ReviewController extends StateNotifier<ReviewState> {
  ReviewController(this.ref, this.adId) : super(const ReviewState()) {
    loadReviews();
  }

  final Ref ref;
  final String adId;

  /// ---------------------------
  /// Load Reviews
  /// ---------------------------
  Future<void> loadReviews() async {
    state = state.copyWith(loading: true, clearError: true);

    final api = ref.read(reviewApiProvider);

    final result = await api.getAdReviews(adId: adId);

    result.fold(
      (failure) {
        state = state.copyWith(loading: false, error: failure.message);
      },
      (payload) {
        final data = payload['data'];

        final summaryJson = data?['summary'];
        final items = data?['reviews'];

        final summary = summaryJson != null
            ? ReviewSummary.fromJson(Map<String, dynamic>.from(summaryJson))
            : null;

        final reviews = (items is List)
            ? items.map((e) {
                return AdReview.fromJson(Map<String, dynamic>.from(e));
              }).toList()
            : <AdReview>[];

        state = state.copyWith(
          loading: false,
          reviews: reviews,
          summary: summary,
        );
      },
    );
  }

  /// ---------------------------
  /// Submit Review
  /// ---------------------------
  Future<bool> submit({
    required double rating,
    required String title,
    required String comment,
    required List<String> images,
  }) async {
    state = state.copyWith(submitting: true, error: null);

    final api = ref.read(reviewApiProvider);

    final res = await api.createAdReview(
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

        /// refresh after submit
        await loadReviews();

        return true;
      },
    );
  }

  /// ---------------------------
  /// Toggle Review
  /// ---------------------------
  Future<Either<String, void>> toggleReaction({
    required String reviewId,
    required bool isLikeAction,
  }) async {
    final api = ref.read(reviewApiProvider);

    final current = state.reviews.firstWhere((r) => r.id == reviewId);

    bool newLiked = current.isLiked;
    bool newDisliked = current.isDisliked;

    int likeCount = current.likeCount;
    int dislikeCount = current.dislikeCount;

    String reaction;

    if (isLikeAction) {
      /// LIKE toggle
      if (current.isLiked) {
        // Unlike
        newLiked = false;
        likeCount = (likeCount - 1).clamp(0, 999999);
        reaction = "Like";
      } else {
        // Like
        newLiked = true;
        likeCount += 1;
        reaction = "Like";

        /// remove dislike if exists
        if (current.isDisliked) {
          newDisliked = false;
          dislikeCount = (dislikeCount - 1).clamp(0, 999999);
        }
      }
    } else {
      /// DISLIKE toggle
      if (current.isDisliked) {
        // Undislike
        newDisliked = false;
        dislikeCount = (dislikeCount - 1).clamp(0, 999999);
        reaction = "Dislike";
      } else {
        // Dislike
        newDisliked = true;
        dislikeCount += 1;
        reaction = "Dislike";

        /// remove like if exists
        if (current.isLiked) {
          newLiked = false;
          likeCount = (likeCount - 1).clamp(0, 999999);
        }
      }
    }

    /// ✅ optimistic update
    final updated = state.reviews.map((r) {
      if (r.id != reviewId) return r;

      return AdReview(
        id: r.id,
        rating: r.rating,
        title: r.title,
        comment: r.comment,
        reviewer: r.reviewer,
        creation: r.creation,
        likeCount: likeCount,
        dislikeCount: dislikeCount,
        isLiked: newLiked,
        isDisliked: newDisliked,
      );
    }).toList();

    state = state.copyWith(reviews: updated);

    final res = await api.toggleReview(reviewId: reviewId, reaction: reaction);

    return res.fold(
      (failure) {
        loadReviews();
        return Either.left(failure.message);
      },
      (_) {
        return Either.right(null);
      },
    );
  }
}
