import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';
import '/core/utils/require_login.dart';
import '/features/reviews/remote.dart';

import 'not_reviewed_card.dart';
import 'review_controller.dart';
import 'utils/dialogues.dart';
import 'widgets/average_section.dart';
import 'widgets/distribution_row.dart';
import 'widgets/tile.dart';

class ProductReviewsCard extends StatelessWidget {
  final String itemName;
  final String webItem;
  final String itemCode;

  const ProductReviewsCard({
    super.key,
    required this.itemName,
    required this.webItem,
    required this.itemCode,
  });

  /// --- Header Row with Action Menu ---
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
            onSelected: (value) async {
              final controller = context.read<ProductReviewsController>();

              // ----- LOGIN GUARD -----
              if (!await requireLogin(context)) return;

              if (value == "review") {
                // ✅ Open dialog & receive Review instance
                final newReview = await openRateDialog(
                  context,
                  itemCode,
                  webItem,
                );

                if (newReview != null && context.mounted) {
                  // ✅ Optimistic local add
                  controller.addLocalReview(newReview);

                  // ✅ Background refresh
                  controller.loadReviews(webItem);
                }
              } else if (value == "report") {
                await openReportDialog(context, webItem, itemCode);
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
      create:
          (_) =>
              ProductReviewsController(remote: ReviewsRemote(sl<APIClient>()))
                ..loadReviews(webItem),

      child: Consumer<ProductReviewsController>(
        builder: (context, controller, _) {
          /// --- Loading State ---
          if (controller.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            );
          }

          /// --- No Reviews Yet ---
          if (!controller.hasReviews) {
            return ProductNotReviewedCard(
              titleRow: _buildTitleRow(context),
              onRate: () async {
                final newReview = await openRateDialog(
                  context,
                  itemCode,
                  webItem,
                );

                if (newReview != null && context.mounted) {
                  controller.addLocalReview(newReview);
                  controller.loadReviews(webItem);
                }
              },
            );
          }

          /// --- Reviews List View ---
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(context),
              const SizedBox(height: 12),
              ReviewsAverageSection(controller: controller),
              ReviewsDistributionRow(controller: controller),
              const Divider(thickness: 1),

              /// Animated review list
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Column(
                  key: ValueKey(controller.reviews.length),
                  children:
                      controller.reviews
                          .map((r) => ReviewsTile(review: r))
                          .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
