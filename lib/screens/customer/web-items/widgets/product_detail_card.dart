import 'package:flutter/material.dart';
import '/shared/models/specifications.dart';

import '/screens/customer/reviews/review_card.dart';

class ProductDetailAndReviews extends StatelessWidget {
  final List<Specification> specs;
  final String itemName;
  final String webItem;
  final String itemCode;

  const ProductDetailAndReviews({
    super.key,
    required this.specs,
    required this.itemName,
    required this.webItem,
    required this.itemCode,
  });

  @override
  Widget build(BuildContext context) {
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

                // ✅ Reviews card handles its own state/fetching
                ProductReviewsCard(
                  itemName: itemName,
                  webItem: webItem,
                  itemCode: itemCode,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
