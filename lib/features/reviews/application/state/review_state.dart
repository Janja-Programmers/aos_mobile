import 'package:africaonlinestores/features/reviews/application/state/review_viewer_state.dart';
import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/features/reviews/domain/review_summary.dart';

class ReviewState {
  final List<AdReview> reviews;
  final ReviewSummary? summary;
  final ReviewViewerState? viewerState;

  final bool loading;
  final String? error;
  final bool submitting;
  final bool viewerStateLoading;

  const ReviewState({
    this.reviews = const [],
    this.summary,
    this.viewerState,
    this.loading = false,
    this.error,
    this.submitting = false,
    this.viewerStateLoading = false,
  });

  /// ✅ Safe copyWith (no accidental null override)
  ReviewState copyWith({
    List<AdReview>? reviews,
    ReviewSummary? summary,
    ReviewViewerState? viewerState,
    bool? loading,
    String? error,
    bool? submitting,
    bool? viewerStateLoading,

    /// 👇 control flags
    bool clearError = false,
    bool clearSummary = false,
    bool clearViewerState = false,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      summary: clearSummary ? null : (summary ?? this.summary),
      viewerState: clearViewerState ? null : (viewerState ?? this.viewerState),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      submitting: submitting ?? this.submitting,
      viewerStateLoading: viewerStateLoading ?? this.viewerStateLoading,
    );
  }

  /// ✅ Initial factory (optional but clean)
  factory ReviewState.initial() => const ReviewState();

  /// ✅ Helpers (VERY useful in UI)
  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasData => reviews.isNotEmpty;
  bool get isEmpty => reviews.isEmpty && !loading;
  bool get isLoading => loading;

  bool get isViewerStateLoading => viewerStateLoading;
  bool get canReview => viewerState?.canReview == true;
  bool get hasReviewed => viewerState?.hasReviewed == true;
  bool get hasCommunicated => viewerState?.hasCommunicated == true;
  String? get reviewBlockReason => viewerState?.reason;
}
