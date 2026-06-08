import 'package:africaonlinestores/features/reviews/application/state/review_state.dart';
import 'package:flutter/material.dart';

Widget buildReviewButton({
  required ReviewState reviewState,
  required VoidCallback onReview,
}) {
  final viewerState = reviewState.viewerState;

  if (reviewState.viewerStateLoading) {
    return const SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: null,
        child: Text('Checking review status...'),
      ),
    );
  }

  if (viewerState == null) {
    return const SizedBox.shrink();
  }

  if (viewerState.hasReviewed) {
    return const SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: null, child: Text('Already Reviewed')),
    );
  }

  if (viewerState.canReview) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onReview,
        child: const Text('Review Product'),
      ),
    );
  }

  if (!viewerState.hasCommunicated) {
    return const SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: null,
        child: Text('Contact seller to review'),
      ),
    );
  }

  return SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: null,
      child: Text(viewerState.reason ?? 'Cannot review this product'),
    ),
  );
}
