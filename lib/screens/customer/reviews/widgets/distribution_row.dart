import 'package:flutter/material.dart';

import '../review_controller.dart';

class ReviewsDistributionRow extends StatelessWidget {
  final ProductReviewsController controller;

  const ReviewsDistributionRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final total = controller.totalReviews == 0 ? 1 : controller.totalReviews;

    // Loop 5 → 1 stars
    return Column(
      children: List.generate(5, (i) {
        final star = 5 - i; // 5, 4, 3, 2, 1 (int)
        final count = controller.reviewsPerRating[star - 1].toInt();
        final percent = total > 0 ? count / total : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 30, child: Text("$star★")),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.black87,
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 40, child: Text("$count")),
            ],
          ),
        );
      }),
    );
  }
}
