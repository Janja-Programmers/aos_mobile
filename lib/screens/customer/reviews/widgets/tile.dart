import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '/features/reviews/entity.dart';

class ReviewsTile extends StatelessWidget {
  final Review review;

  const ReviewsTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                rating: review.rating,
                itemBuilder:
                    (_, _) => const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 16.0,
                direction: Axis.horizontal,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(review.comment),
          const SizedBox(height: 6),
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
          const Divider(),
        ],
      ),
    );
  }
}
