import 'package:flutter/material.dart';

class ProductAvailability extends StatelessWidget {
  final bool inStock;
  final String productName;

  const ProductAvailability({
    super.key,
    required this.inStock,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(inStock ? "In Stock" : "Out of Stock"),
      backgroundColor: inStock ? Colors.green.shade100 : Colors.red.shade100,
      labelStyle: TextStyle(
        color: inStock ? Colors.green.shade800 : Colors.red.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
