import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../widgets/rate_product.dart';
import '../../widgets/report_product.dart';
import '/features/reviews/entity.dart';
import '/core/utils/snackbar.dart';

import 'not_reviewed_card.dart';
import 'review_controller.dart';

/// ProductReviewsCard is a dumb/presentational widget:
/// - accepts a controller that has precomputed values
/// - accepts callbacks or uses simple dialogs for rate/report
class ProductReviewsCard extends StatelessWidget {
  final ProductReviewsController controller;
  final String productName;

  /// Optional callbacks if parent wants to perform additional work
  final Future<void> Function()? onAfterSubmit;
  final Future<void> Function()? onAfterReport;

  const ProductReviewsCard({
    super.key,
    required this.controller,
    required this.productName,
    this.onAfterSubmit,
    this.onAfterReport,
  });

  Future<void> _openRateDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RateProductDialog(productName: productName),
    );

    if (result == true) {
      topSnackBar(context, "Review submitted successfully ✅");
      if (onAfterSubmit != null) await onAfterSubmit!();
    }
  }

  Future<void> _openReportDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ReportProductDialog(productName: productName),
    );

    if (result == true) {
      topSnackBar(context, "Report submitted successfully 🚨");
      if (onAfterReport != null) await onAfterReport!();
    }
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Customer Reviews",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "review") {
                _openRateDialog(context);
              } else if (value == "report") {
                _openReportDialog(context);
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: "review",
                    child: Text("✍️ Review product"),
                  ),
                  PopupMenuItem(
                    value: "report",
                    child: Text("🚩 Report product"),
                  ),
                ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Action",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAverageSection() {
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
          // Half-star friendly indicator using flutter_rating_bar
          RatingBarIndicator(
            rating: avg,
            itemBuilder:
                (context, index) => const Icon(Icons.star, color: Colors.amber),
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

  Widget _buildDistributionRow(BuildContext context) {
    final dist = controller.ratingDistribution;
    final total = controller.totalReviews == 0 ? 1 : controller.totalReviews;

    return Column(
      children: List.generate(5, (i) {
        final star = 5 - i;
        final count = dist[star] ?? 0;
        final percent = count / total;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text("$star star")),
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
              SizedBox(
                width: 50,
                child: Text("${(percent * 100).toStringAsFixed(1)}%"),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewTile(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(context),
          const SizedBox(height: 12),

          // If no reviews -> show a friendly card that invites to review
          if (!controller.hasReviews) ...[
            ProductNotReviewedCard(onRate: () => _openRateDialog(context)),
          ] else ...[
            _buildAverageSection(),
            const SizedBox(height: 16),
            _buildDistributionRow(context),
            const SizedBox(height: 20),

            // Reviews list — use ListView when the list grows, but for embedding inside a column
            ...controller.reviews.map(_buildReviewTile),
          ],
        ],
      ),
    );
  }
}
