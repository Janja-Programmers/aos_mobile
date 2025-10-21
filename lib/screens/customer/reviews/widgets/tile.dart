import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '/features/reviews/entity.dart';

class ReviewsTile extends StatelessWidget {
  final Review review;

  const ReviewsTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final normalized = double.tryParse(review.rating.toString()) ?? 0.0;
    final displayRating = (normalized * 5).clamp(0.0, 5.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title + Stars ---
          Row(
            children: [
              Expanded(
                child: Text(
                  review.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              RatingBarIndicator(
                rating: displayRating,
                itemBuilder:
                    (_, _) => const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 16.0,
                unratedColor: Colors.grey.shade300,
              ),
            ],
          ),

          const SizedBox(height: 4),

          // --- Comment ---
          if (review.comment.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(review.comment, style: const TextStyle(fontSize: 14)),
            ),

          // --- Author + Date ---
          Row(
            children: [
              Text(
                review.customer,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(width: 6),
              Text(
                review.publishedOn,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Divider(height: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}
