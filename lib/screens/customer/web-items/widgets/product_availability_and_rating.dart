import 'package:flutter/material.dart';

class ProductAvailabilityAndRating extends StatelessWidget {
  final bool inStock;
  final double rating;
  final int totalReviews;

  const ProductAvailabilityAndRating({
    super.key,
    required this.inStock,
    required this.rating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          inStock ? 'In Stock' : 'Out of Stock',
          style: TextStyle(
            color: inStock ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        // const SizedBox(width: 8),
        // Text(
        //   '⭐ ${rating.toStringAsFixed(1)}${totalReviews > 0 ? ' ($totalReviews)' : ''}',
        //   style: TextStyle(color: Colors.black87),
        // ),
      ],
    );
  }
}
