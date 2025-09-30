import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../review_controller.dart';

class ReviewsAverageSection extends StatelessWidget {
  final ProductReviewsController controller;

  const ReviewsAverageSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final avg = controller.averageRating;

    return Center(
      child: Column(
        children: [
          Text(
            avg.toStringAsFixed(1),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          Text(
            "${controller.totalReviews} ratings",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          RatingBarIndicator(
            rating: avg,
            itemBuilder: (_, _) => const Icon(Icons.star, color: Colors.amber),
            itemCount: 5,
            itemSize: 24.0,
            direction: Axis.horizontal,
          ),
          const SizedBox(height: 4),
          Text(
            "${avg.toStringAsFixed(1)} out of 5",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
