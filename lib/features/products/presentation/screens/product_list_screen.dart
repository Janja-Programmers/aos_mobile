import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Product Feature
import '../product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter.dart';
import '../widgets/supplier_contact_sheet.dart';

// Wishlist Feature
import '../../../wishlist/presentation/wishlist_provider.dart';
import '../../../wishlist/domain/wishlist_item.dart';

// Cart Feature
import '../../../cart/presentation/cart_provider.dart';
import '../../../cart/domain/cart_item.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedCategory = 'All';
  List<bool> _itemVisible = [];

  @override
  void initState() {
    super.initState();

    // Defer everything until after the first frame to safely use context
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      await provider.loadProducts();

      if (!mounted) return;

      // Initialize visibility list based on product count
      _itemVisible = List.filled(provider.products.length, false);

      // Staggered animation
      for (int i = 0; i < provider.products.length; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        setState(() {
          _itemVisible[i] = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    final filteredProducts =
        _selectedCategory == 'All'
            ? provider.products
            : provider.products
                .where((p) => p.category == _selectedCategory)
                .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Wishlist',
            onPressed: () => context.push('/wishlist'),
          ),
        ],
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? Center(child: Text(provider.error!))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: ProductFilter(
                      categories: const [
                        'All',
                        'Electronics',
                        'Fashion',
                        'Home',
                      ],
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child:
                        filteredProducts.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    '😕 No products found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text('Try selecting a different category'),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final isVisible =
                                    index < _itemVisible.length
                                        ? _itemVisible[index]
                                        : false;

                                return AnimatedOpacity(
                                  opacity: isVisible ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  child: ProductCard(
                                    product: product,
                                    onTap: () {
                                      provider.loadProductDetails(product.id);
                                      context.push('/product/${product.id}');
                                    },
                                    isFavorite: wishlist.isInWishlist(
                                      product.id,
                                    ),
                                    onFavToggle: () {
                                      final item = WishlistItem(
                                        id: product.id,
                                        title: product.title,
                                        imageUrl: product.imageUrl,
                                        price: product.price,
                                      );

                                      if (wishlist.isInWishlist(product.id)) {
                                        wishlist.remove(product.id);
                                      } else {
                                        wishlist.add(item);
                                      }

                                      setState(
                                        () {},
                                      ); // <- ensure the heart icon updates
                                    },

                                    onCartToggle: () {
                                      final isNew =
                                          !cart.items.any(
                                            (e) => e.id == product.id,
                                          );

                                      final item = CartItem(
                                        id: product.id,
                                        title: product.title,
                                        imageUrl: product.imageUrl,
                                        price: product.price,
                                        quantity: 1,
                                      );

                                      cart.add(item);

                                      if (isNew) {
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            const SnackBar(
                                              content: Text('🛒 Added to Cart'),
                                            ),
                                          );
                                      }
                                    },

                                    onCallTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder:
                                            (_) => SupplierContactSheet(
                                              product: product,
                                            ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
