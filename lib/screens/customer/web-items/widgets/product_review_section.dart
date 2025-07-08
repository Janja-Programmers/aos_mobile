import 'package:flutter/material.dart';

class ProductReviewsSection extends StatelessWidget {
  final double rating;
  final int totalReviews;

  const ProductReviewsSection({
    super.key,
    required this.rating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Reviews",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text("$totalReviews reviews • Average rating: $rating ⭐"),
        // You can expand this with a full review list later
      ],
    );
  }
}
