import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/cart/domain/cart.dart';
import '/features/cart/provider.dart';
import '/features/website/prov.dart';

import '/shared/widgets/app_bars.dart';
import '/shared/widgets/cart_button.dart';

import '../widgets/product_availability_and_rating.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image_with_video.dart';
import '../widgets/product_review_section.dart';
import '../widgets/product_specification_list.dart';
import '../widgets/product_tile_and_price.dart';
import '../helper/empty_page.dart';
import '../helper/contact_vendor.dart';
import '../helper/add_to_cart_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WebsiteItemProv>().loadProductDetail(widget.productId);
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
      debugPrint('❌ Error loading product: ${provider.error}');

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
                const SizedBox(height: 12),
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
                          () => provider.loadProductDetail(widget.productId),
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

    final cartProvider = context.watch<CartProvider>();
    final isInCart = cartProvider.containsProduct(product.name);

    final cartItem = CartItem(
      code: product.itemCode,
      name: product.name,
      price: product.price,
      quantity: 1,
    );

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
                : [
                  const CartIconButton(),
                  IconButton(
                    icon: const Icon(Icons.person, color: AppColors.black),
                    onPressed: () {},
                  ),
                ],
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
                  ProductImageWithVideo(
                    imageUrls: product.images,
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

                  const SizedBox(height: 12),

                  if (!product.inStock)
                    const Chip(
                      label: Text('Not in stock'),
                      backgroundColor: Color.fromARGB(255, 235, 87, 87),
                      labelStyle: TextStyle(color: Colors.white),
                    ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child:
                            product.inStock
                                ? isInCart
                                    ? ElevatedButton.icon(
                                      onPressed: () => context.go('/cart'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.shopping_cart),
                                      label: const Text('View in Cart'),
                                    )
                                    : AddToCartButton(item: cartItem)
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ContactVendorButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Contact Vendor tapped"),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // --- Conditional Description ---
                  if ((product.shortDescription.isNotEmpty) ||
                      (product.longDescription.isNotEmpty)) ...[
                    ProductDescriptions(
                      shortDesc: product.shortDescription,
                      longDesc: product.longDescription,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // --- Conditional Specs ---
                  if (product.specifications.isNotEmpty) ...[
                    ProductSpecificationsList(specs: product.specifications),
                    const SizedBox(height: 12),
                  ],

                  // --- Conditional Reviews ---
                  if (product.reviews.isNotEmpty) ...[
                    ProductReviews(reviews: product.reviews),
                    const SizedBox(height: 12),
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
