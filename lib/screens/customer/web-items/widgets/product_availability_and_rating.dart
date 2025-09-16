import 'package:flutter/material.dart';

import '/core/utils/snackbar.dart';

import '../../../widgets/rate_product.dart';
import '../../../widgets/report_product.dart';

class ProductAvailabilityAndRating extends StatelessWidget {
  final bool inStock;
  final double rating;
  final int totalReviews;
  final String productName;
  final VoidCallback? onWriteReview;
  final VoidCallback? onReport;

  const ProductAvailabilityAndRating({
    super.key,
    required this.inStock,
    required this.rating,
    required this.totalReviews,
    required this.productName,
    this.onWriteReview,
    this.onReport,
  });

  void _openRateDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => RateProductDialog(productName: productName),
    );
    if (result == true) {
      onWriteReview?.call();
      topSnackBar(context, "Review submitted successfully ✅");
    }
  }

  void _openReportDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => ReportProductDialog(productName: productName),
    );
    if (result == true) {
      onReport?.call();
      topSnackBar(context, "Report submitted successfully 🚨");
    }
  }

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
        const Spacer(),
        if (totalReviews > 0)
          Text(
            '⭐ ${rating.toStringAsFixed(1)} ($totalReviews)',
            style: const TextStyle(color: Colors.black87),
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) {
            if (value == 'rate') _openRateDialog(context);
            if (value == 'report') _openReportDialog(context);
          },
          itemBuilder:
              (context) => const [
                PopupMenuItem(value: 'rate', child: Text('Write a Review')),
                PopupMenuItem(value: 'report', child: Text('Report Product')),
              ],
        ),
      ],
    );
  }
}
