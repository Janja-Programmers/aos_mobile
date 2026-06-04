class ReviewViewerState {
  final bool canReview;
  final String? reason;
  final bool hasReviewed;
  final bool hasCommunicated;

  const ReviewViewerState({
    required this.canReview,
    required this.reason,
    required this.hasReviewed,
    required this.hasCommunicated,
  });

  factory ReviewViewerState.fromJson(Map<String, dynamic> json) {
    return ReviewViewerState(
      canReview: json['can_review'] == true,
      reason: json['reason'] as String?,
      hasReviewed: json['has_reviewed'] == true,
      hasCommunicated: json['has_communicated'] == true,
    );
  }
}
