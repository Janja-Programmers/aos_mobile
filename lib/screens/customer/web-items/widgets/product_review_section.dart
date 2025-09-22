import 'package:flutter/material.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../widgets/rate_product.dart';
import '../../../widgets/report_product.dart';
import '/features/reviews/entity.dart';

class ProductReviews extends StatelessWidget {
  final List<Review> reviews;
  final String productName;

  const ProductReviews({
    super.key,
    required this.reviews,
    required this.productName,
  });

  double _averageRating() {
    if (reviews.isEmpty) return 0;
    return reviews.map((e) => e.rating.toDouble()).reduce((a, b) => a + b) /
        reviews.length;
  }

  Map<int, int> _ratingDistribution() {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      final ratingInt = r.rating.toInt();
      dist[ratingInt] = dist[ratingInt]! + 1;
    }
    return dist;
  }

  void _openRateDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => RateProductDialog(productName: productName),
    );
    if (result == true) {
      topSnackBar(context, "Review submitted successfully ✅");
    }
  }

  void _openReportDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => ReportProductDialog(productName: productName),
    );
    if (result == true) {
      topSnackBar(context, "Report submitted successfully 🚨");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text("No reviews yet."));
    }

    final avgRating = _averageRating();
    final dist = _ratingDistribution();

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Actions
          Row(
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
                      (context) => [
                        const PopupMenuItem(
                          value: "review",
                          child: Text("✍️ Review product"),
                        ),
                        const PopupMenuItem(
                          value: "report",
                          child: Text("🚩 Report product"),
                        ),
                      ],
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      "Action",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Average rating + star row
          Center(
            child: Column(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${reviews.length} ratings",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < avgRating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${avgRating.toStringAsFixed(1)} out of 5",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Rating distribution bars
          Column(
            children: List.generate(5, (i) {
              final star = 5 - i;
              final count = dist[star] ?? 0;
              final percent = count / reviews.length;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text("$star star"),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.black87,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("${(percent * 100).toStringAsFixed(1)}%"),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Individual reviews
          ...reviews.map((review) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + stars
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
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
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
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        review.publishedOn,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
