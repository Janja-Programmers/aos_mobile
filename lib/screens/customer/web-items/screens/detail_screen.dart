import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/website/prov.dart';

import '/shared/widgets/app_bars.dart';
import '/shared/widgets/cart_button.dart';

import '../widgets/product_action_bar.dart';
import '../widgets/product_availability_and_rating.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image_with_video.dart';
import '../widgets/product_review_section.dart';
import '../widgets/product_specification_list.dart';
import '../widgets/product_tile_and_price.dart';

import '../helper/empty_page.dart';

class ProductDetailScreen extends StatefulWidget {
  final String itemCode;

  const ProductDetailScreen({super.key, required this.itemCode});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<WebsiteItemProv>().selectedProduct?.itemCode !=
          widget.itemCode) {
        context.read<WebsiteItemProv>().loadProductDetail(widget.itemCode);
      }
    });
  }

  WebsiteItemProv? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider ??= context.read<WebsiteItemProv>();
  }

  @override
  void dispose() {
    _provider?.clearProductDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<WebsiteItemProv>();

    final product = provider.selectedProduct;
    final isLoading = provider.isLoading;
    final error = provider.error;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: TopAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      debugPrint('❌ Failed to load product "${widget.itemCode}"');

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: TopAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 6),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Oops! Product escaped from us. Please try again later.',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          () => provider.loadProductDetail(widget.itemCode),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Continue Shopping'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (product == null) {
      return const EmptyProductPage();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(
        actions:
            user == null
                ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextButton(
                      onPressed: () => context.push('/login'),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ]
                : [const CartIconButton()],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductImageWithVideo(
                            imageUrls:
                                product.images.isNotEmpty
                                    ? product.images
                                    : [product.imageUrl],
                            videoUrl: product.demoVideoUrl ?? "",
                          ),

                          const SizedBox(height: 16),

                          ProductTitleAndPrice(
                            title: product.id,
                            category: product.itemGroup,
                            price: product.price,
                          ),
                          const SizedBox(height: 8),

                          ProductAvailabilityAndRating(
                            inStock: product.inStock,
                            rating:
                                product.reviews.isNotEmpty
                                    ? product.reviews
                                            .map((e) => e.rating)
                                            .reduce((a, b) => a + b) /
                                        product.reviews.length
                                    : 0.0,
                            totalReviews: product.reviews.length,
                          ),

                          const SizedBox(height: 6),

                          ProductActionBar(product: product),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),

                  // --- Conditional Description ---
                  if ((product.shortDescription.isNotEmpty) ||
                      (product.longDescription.isNotEmpty)) ...[
                    ProductDescriptions(
                      shortDesc: product.shortDescription,
                      longDesc: product.longDescription,
                    ),
                    const SizedBox(height: 6),
                  ],

                  // --- Conditional Specs ---
                  if (product.specifications.isNotEmpty) ...[
                    ProductSpecificationsList(specs: product.specifications),
                    const SizedBox(height: 6),
                  ],

                  // --- Conditional Reviews ---
                  if (product.reviews.isNotEmpty) ...[
                    ProductReviews(reviews: product.reviews),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
