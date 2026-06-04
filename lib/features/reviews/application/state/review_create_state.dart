class ReviewCreateState {
  final bool submitting;
  final String? error;

  const ReviewCreateState({this.submitting = false, this.error});

  ReviewCreateState copyWith({bool? submitting, String? error}) {
    return ReviewCreateState(
      submitting: submitting ?? this.submitting,
      error: error,
    );
  }
}
