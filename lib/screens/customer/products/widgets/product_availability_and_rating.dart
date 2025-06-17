import 'package:flutter/material.dart';

class ProductAvailabilityAndRating extends StatelessWidget {
  final bool inStock;
  final double rating;

  const ProductAvailabilityAndRating({
    super.key,
    required this.inStock,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Chip(
          label: Text(inStock ? 'In Stock' : 'Out of Stock'),
          backgroundColor: inStock ? Colors.green[100] : Colors.red[100],
        ),
        const SizedBox(width: 8),
        Chip(label: Text('⭐ ${rating.toStringAsFixed(1)}')),
      ],
    );
  }
}
