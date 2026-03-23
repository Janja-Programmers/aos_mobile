import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/features/reviews/domain/review_summary.dart';

class ReviewState {
  final List<AdReview> reviews;
  final ReviewSummary? summary;
  final bool loading;
  final String? error;
  final bool submitting;

  const ReviewState({
    this.reviews = const [],
    this.summary,
    this.loading = false,
    this.error,
    this.submitting = false,
  });

  /// ✅ Safe copyWith (no accidental null override)
  ReviewState copyWith({
    List<AdReview>? reviews,
    ReviewSummary? summary,
    bool? loading,
    String? error,
    bool? submitting,

    /// 👇 control flags
    bool clearError = false,
    bool clearSummary = false,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      summary: clearSummary ? null : (summary ?? this.summary),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      submitting: submitting ?? this.submitting,
    );
  }

  /// ✅ Initial factory (optional but clean)
  factory ReviewState.initial() => const ReviewState();

  /// ✅ Helpers (VERY useful in UI)
  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasData => reviews.isNotEmpty;
  bool get isEmpty => reviews.isEmpty && !loading;
  bool get isLoading => loading;
}
