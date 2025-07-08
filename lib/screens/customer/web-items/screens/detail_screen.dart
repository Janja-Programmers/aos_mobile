import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../helper/contact_vendor.dart';
import '/core/constants/colors.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/cart/domain/cart.dart';
import '/features/cart/provider.dart';
import '/features/website/domain/webitem.dart';
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
import '../helper/add_to_cart_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<WebsiteItemProv>();

    final product = provider.items.firstWhere(
      (p) => p.name == productId,
      orElse:
          () => WebsiteItem(
            name: '',
            id: '',
            owner: '',
            title: '',
            itemCode: '',
            itemGroup: '',
            thumbnailUrl: '',
            imageUrl: '',
            description: '',
            shortDescription: '',
            longDescription: '',
            published: true,
            onBackorder: true,
            specifications: [],
          ),
    );

    final cartProvider = context.watch<CartProvider>();
    final isInCart = cartProvider.containsProduct(product.name);

    if (product.name.isEmpty) return const EmptyProductPage();

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
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white70,
            child: const Text(
              'Product detail',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // 🔻 Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Hero image
                  Hero(
                    tag: 'product-${product.name}',
                    child: ProductImageWithVideo(
                      imageUrl: product.imageUrl,
                      videoUrl: product.demoVideoUrl ?? "",
                    ),
                  ),
                  const SizedBox(height: 16),

                  ProductTitleAndPrice(
                    title: product.name,
                    category: product.itemGroup,
                    price: product.price,
                  ),
                  const SizedBox(height: 8),

                  ProductAvailabilityAndRating(
                    inStock: product.inStock,
                    rating: 0,
                  ),

                  const SizedBox(height: 12),

                  // 🔴 In stock / out of stock handling
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
                            // TODO: Replace with real contact action
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

                  const SizedBox(height: 16),

                  ProductDescriptions(
                    shortDesc: product.shortDescription,
                    longDesc: product.description,
                  ),
                  const SizedBox(height: 16),

                  ProductSpecificationsList(specs: product.specifications),
                  const SizedBox(height: 16),

                  ProductReviewsSection(rating: 0, totalReviews: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
