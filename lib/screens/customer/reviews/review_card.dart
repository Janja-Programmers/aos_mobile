import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/dialogues.dart';

import 'widgets/average_section.dart';
import 'widgets/distribution_row.dart';
import 'widgets/tile.dart';

import 'not_reviewed_card.dart';
import 'review_controller.dart';

class ProductReviewsCard extends StatelessWidget {
  final String itemCode;

  const ProductReviewsCard({super.key, required this.itemCode});

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
                openRateDialog(context, itemCode);
              } else if (value == "report") {
                openReportDialog(context, itemCode);
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductReviewsController()..loadReviews(itemCode, context),
      child: Consumer<ProductReviewsController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasReviews) {
            return ProductNotReviewedCard(
              onRate: () async {
                await openRateDialog(context, itemCode);
                controller.loadReviews(itemCode, context);
              },
              titleRow: _buildTitleRow(
                context,
              ), // <-- inject the same title row
            );
          }

          return Column(
            children: [
              _buildTitleRow(context),
              const SizedBox(height: 12),
              ReviewsAverageSection(controller: controller),
              ReviewsDistributionRow(controller: controller),
              ...controller.reviews.map((r) => ReviewsTile(review: r)),
            ],
          );
        },
      ),
    );
  }
}
