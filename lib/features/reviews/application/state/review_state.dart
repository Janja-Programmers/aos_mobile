import 'package:africaonlinestores/features/reviews/application/state/review_viewer_state.dart';
import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/features/reviews/domain/review_sort.dart';
import 'package:africaonlinestores/features/reviews/domain/review_summary.dart';

class ReviewState {
  final List<AdReview> reviews;
  final ReviewSummary? summary;
  final ReviewViewerState? viewerState;
  final ReviewSort sort;
  final int? ratingFilter;

  final bool loading;
  final String? error;
  final bool submitting;
  final bool viewerStateLoading;

  const ReviewState({
    this.reviews = const [],
    this.summary,
    this.viewerState,
    this.sort = ReviewSort.newest,
    this.ratingFilter,
    this.loading = false,
    this.error,
    this.submitting = false,
    this.viewerStateLoading = false,
  });

  ReviewState copyWith({
    List<AdReview>? reviews,
    ReviewSummary? summary,
    ReviewViewerState? viewerState,
    ReviewSort? sort,
    int? ratingFilter,
    bool? loading,
    String? error,
    bool? submitting,
    bool? viewerStateLoading,
    bool clearError = false,
    bool clearSummary = false,
    bool clearViewerState = false,
    bool clearRatingFilter = false,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      summary: clearSummary ? null : (summary ?? this.summary),
      viewerState: clearViewerState ? null : (viewerState ?? this.viewerState),
      sort: sort ?? this.sort,
      ratingFilter: clearRatingFilter
          ? null
          : (ratingFilter ?? this.ratingFilter),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      submitting: submitting ?? this.submitting,
      viewerStateLoading: viewerStateLoading ?? this.viewerStateLoading,
    );
  }

  factory ReviewState.initial() => const ReviewState();

  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasData => reviews.isNotEmpty;
  bool get isEmpty => reviews.isEmpty && !loading;
  bool get isLoading => loading;
  bool get hasRatingFilter => ratingFilter != null;

  bool get isViewerStateLoading => viewerStateLoading;
  bool get canReview => viewerState?.canReview == true;
  bool get hasReviewed => viewerState?.hasReviewed == true;
  bool get hasCommunicated => viewerState?.hasCommunicated == true;
  String? get reviewBlockReason => viewerState?.reason;
}
