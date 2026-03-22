import 'package:africaonlinestores/features/reviews/domain/review_model.dart';

class ReviewState {
  final List<AdReview> reviews;
  final bool loading;
  final String? error;

  /// submit state
  final bool submitting;

  const ReviewState({
    this.reviews = const [],
    this.loading = false,
    this.error,
    this.submitting = false,
  });

  ReviewState copyWith({
    List<AdReview>? reviews,
    bool? loading,
    String? error,
    bool? submitting,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      loading: loading ?? this.loading,
      error: error,
      submitting: submitting ?? this.submitting,
    );
  }
}
