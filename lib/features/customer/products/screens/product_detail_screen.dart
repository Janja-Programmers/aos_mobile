import 'package:flutter/material.dart';

import '/features/website/domain/webitem.dart';

import '../widgets/product_action_buttons.dart';
import '../widgets/product_availability_and_rating.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image_with_video.dart';
import '../widgets/product_review_section.dart';
import '../widgets/product_specification_list.dart';
import '../widgets/product_tile_and_price.dart';

class ProductDetailScreen extends StatelessWidget {
  final WebsiteItem product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageWithVideo(
              imageUrl: product.imageUrl,
              videoUrl: product.demoVideoUrl ?? "",
            ),
            const SizedBox(height: 16),

            ProductTitleAndPrice(
              title: product.name,
              category: product.itemGroup,
              price: 0.00,
            ),
            const SizedBox(height: 8),

            ProductAvailabilityAndRating(
              inStock: product.onBackorder,
              rating: 0,
            ),
            const SizedBox(height: 16),

            ProductActionButtons(
              onAddToCart: () {
                // Call your add-to-cart logic
              },
              onContact: () {
                // Show vendor contact sheet
              },
            ),
            const SizedBox(height: 16),

            ProductDescriptions(
              shortDesc: product.shortDescription,
              longDesc: product.longDescription,
            ),
            const SizedBox(height: 16),

            ProductSpecificationsList(specs: []),
            const SizedBox(height: 16),

            ProductReviewsSection(rating: 0, totalReviews: 0),
          ],
        ),
      ),
    );
  }
}
