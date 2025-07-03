import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ownashop/core/utils/snackbar.dart';
import 'package:ownashop/screens/customer/products/utils/vendor_prov.dart';
import 'package:provider/provider.dart';

import '../utils/url_launcher.dart';
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

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  void addToCart(Product product) async {
    final cart = context.read<CartProvider>();
    final success = await cart.add(
      CartItem(
        code: product.name,
        name: product.itemName,
        price: product.itemPrice,
        quantity: 1,
        image: product.image,
      ),
    );

    if (success) {
      topSnackBar(
        context,
        '${product.itemName} added to cart',
        type: TopSnackType.success,
      );
    }
  }

  void contactVendor(Product product) async {
    final vendorProvider = context.read<VendorProvider>();
    await vendorProvider.loadVendor(product.vendor ?? 'Unknown');

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder:
          (_) => Consumer<VendorProvider>(
            builder: (context, provider, _) {
              if (provider.loading) {
                return const AlertDialog(
                  content: SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final vendor = provider.vendor;
              if (vendor == null) {
                return const AlertDialog(
                  title: Text('Error'),
                  content: Text('Failed to load vendor details.'),
                );
              }

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text('Supplier: ${vendor.name}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vendor.email.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('📧 ${vendor.email}'),
                      ),
                    if (vendor.phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('📞 ${vendor.phone}'),
                      ),
                  ],
                ),
                actions: [
                  if (vendor.phone.isNotEmpty)
                    TextButton(
                      onPressed: () => launchCaller(vendor.phone),
                      child: const Text(
                        'Call',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<ProductProvider>();

    final product = provider.products.firstWhere(
      (p) => p.name == widget.productId,
      orElse:
          () => Product(
            name: '',
            itemName: '',
            itemPrice: 0,
            category: '',
            image: '',
            demoVideo: '',
            shortWebsiteDescription: '',
            websiteDescription: '',
            websiteSpecifications: [],
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
                    onAddToCart: () => addToCart(product),
                    onViewCart: () => context.push('/cart'),
                    onContact: () => contactVendor(product),
                  ),
                  const SizedBox(height: 16),
                  ProductDescriptions(
                    shortDesc:
                        product.shortWebsiteDescription ?? 'About this product',
                    longDesc: product.websiteDescription ?? '',
                  ),
                  const SizedBox(height: 16),
                  ProductSpecificationsList(
                    specs: product.websiteSpecifications ?? [],
                  ),
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
