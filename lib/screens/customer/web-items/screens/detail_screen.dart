import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/product/provider.dart';
import '/features/cart/provider.dart';
import '/features/cart/domain/cart.dart';
import '/features/product/domain/product.dart';

import '/shared/widgets/cart_button.dart';
import '/shared/widgets/app_bars.dart';

import '../widgets/product_action_buttons.dart';
import '../widgets/product_availability_and_rating.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image_with_video.dart';
import '../widgets/product_review_section.dart';
import '../widgets/product_specification_list.dart';
import '../widgets/product_tile_and_price.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<ProductProvider>();
    final product = provider.products.firstWhere(
      (p) => p.name == productId,
      orElse:
          () => Product(
            name: '',
            itemName: '',
            itemPrice: 0,
            category: '',
            image: '',
            demoVideo: '',
          ),
    );

    if (product.name.isEmpty) {
      return const Scaffold(body: Center(child: Text('Product not found')));
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
                      onPressed: () {
                        context.push('/login');
                      },
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
                  ProductImageWithVideo(
                    imageUrl: product.image ?? "",
                    videoUrl: product.demoVideo ?? "",
                  ),
                  const SizedBox(height: 16),

                  ProductTitleAndPrice(
                    title: product.itemName,
                    category: product.category,
                    price: product.itemPrice,
                  ),
                  const SizedBox(height: 8),

                  ProductAvailabilityAndRating(inStock: true, rating: 0),
                  const SizedBox(height: 16),

                  ProductActionButtons(
                    isInCart: context.watch<CartProvider>().containsProduct(
                      product.name,
                    ),
                    onAddToCart: () {
                      final cart = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );

                      final cartItem = CartItem(
                        code: product.name,
                        name: product.itemName,
                        price: product.itemPrice,
                        quantity: 1,
                      );

                      cart.addToCart(cartItem);

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text('${product.itemName} added to cart'),
                          ),
                        );
                    },
                    onViewCart: () {
                      context.go('/cart');
                    },

                    onContact: () {},
                  ),

                  const SizedBox(height: 16),

                  ProductDescriptions(
                    shortDesc: product.shortWebsiteDescription ?? '',
                    longDesc: product.websiteDescription ?? '',
                  ),
                  const SizedBox(height: 16),

                  ProductSpecificationsList(specs: []),
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
