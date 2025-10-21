import 'package:flutter/material.dart';

import '../review_controller.dart';

class ReviewsDistributionRow extends StatelessWidget {
  final ProductReviewsController controller;

  const ReviewsDistributionRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // final star = 5 - i; Reveresed star list

    return Column(
      children: List.generate(5, (i) {
        final star = i + 1;
        final count = controller.reviewsPerRating[star - 1].toDouble();
        final percent = count > 0 ? (count / 100) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 30, child: Text("$star ⭐")),
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
              SizedBox(width: 40, child: Text("$count %")),
            ],
          ),
        );
      }),
    );
  }
}
