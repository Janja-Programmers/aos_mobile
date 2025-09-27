import 'package:flutter/material.dart';

import '/shared/models/specifications.dart';
import '/features/reviews/entity.dart';
import '/screens/customer/reviews/review_controller.dart';
import '/screens/customer/reviews/review_card.dart';

class ProductDetailAndReviews extends StatelessWidget {
  final List<Specification> specs;
  final List<Review> reviews;

  const ProductDetailAndReviews({
    super.key,
    required this.specs,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    // Always render the card so users see the reviews area (even if empty)
    final controller = ProductReviewsController(reviews: reviews);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product specs (only if present)
                if (specs.isNotEmpty) ...[
                  const Text(
                    "Product Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1),
                  ...specs.map(
                    (spec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              spec.label,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              spec.description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1),
                ],

                // Reviews (always shown)
                ProductReviewsCard(
                  controller: controller,
                  productName: specs.isNotEmpty ? specs.first.label : "Product",
                  // optionally: onAfterSubmit: () => yourProvider.fetchReviews() ...
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
