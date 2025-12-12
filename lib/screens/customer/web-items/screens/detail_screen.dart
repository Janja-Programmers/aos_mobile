import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/website/prov.dart';
import '/features/wishlist/domain/wishlist_item.dart';
import '/features/wishlist/provider.dart';

import '/shared/widgets/app_bars.dart';
import '/shared/widgets/app_bottom_nav.dart';

import '../widgets/product_action_bar.dart';
import '../widgets/product_availability.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image_with_video.dart';
import '../widgets/product_detail_card.dart';
import '../widgets/product_tile_and_price.dart';

import '../helper/add_to_wishlist.dart';
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
    _provider?.silentClearProductDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => context.push('/'),
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
      appBar: TopAppBar(),
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: Column(
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
                            Stack(
                              children: [
                                ProductImageWithVideo(
                                  imageUrls:
                                      product.images.isNotEmpty
                                          ? product.images
                                          : [product.imageUrl],
                                  videoUrl: product.demoVideoUrl ?? "",
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Builder(
                                    builder: (context) {
                                      final wishlistProv =
                                          context.watch<WishlistProvider>();
                                      final isWished = wishlistProv
                                          .isInWishlist(product.itemCode);

                                      return InkWell(
                                        onTap: () {
                                          handleToggleWishlist(
                                            context,
                                            wishlistProv,
                                            WishlistItem(
                                              id: product.itemCode,
                                              title: product.name,
                                              imageUrl: product.imageUrl,
                                              price: product.price.toDouble(),
                                              itemGroup: product.itemGroup,
                                              inStock: product.inStock,
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          isWished
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              isWished
                                                  ? Colors.red
                                                  : Colors.grey,
                                          size: 28,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            ProductTitleAndPrice(
                              title: product.id,
                              category: product.itemGroup,
                              price: product.price,
                            ),
                            const SizedBox(height: 8),

                            ProductAvailability(
                              inStock: product.inStock,
                              productName: product.name,
                            ),
                            const SizedBox(height: 6),

                            ProductActionBar(product: product),
                            const SizedBox(height: 6),

                            ProductDescription(
                              shortDesc: product.shortDescription,
                              longDesc: product.longDescription,
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),

                    // --- Product Details and Reviews ---
                    ProductDetailAndReviews(
                      specs: product.specifications,
                      itemName: product.name,
                      webItem: product.title,
                      itemCode: product.itemCode,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
