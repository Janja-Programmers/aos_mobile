import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/formatters.dart';

class ProductTitleAndPrice extends StatelessWidget {
  final String title;
  final String category;
  final double price;
  final double? oldPrice;

  const ProductTitleAndPrice({
    super.key,
    required this.title,
    required this.category,
    required this.price,
    this.oldPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(category, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          formatCurrency(price),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        if (oldPrice != null)
          Text(
            formatCurrency(oldPrice!),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}
