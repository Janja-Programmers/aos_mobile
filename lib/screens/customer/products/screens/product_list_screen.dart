import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/core/utils/formatters.dart';

import '/shared/widgets/app_bars.dart';
import '/shared/widgets/cart_button.dart';
import '/shared/widgets/add_to_cart_button.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/product/provider.dart';
// import '/features/website/prov.dart';

import '/features/cart/domain/cart.dart';

import '../widgets/image_or_placeholder.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    // final wishlist = context.watch<WishlistProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    final items =
        productProvider.products
            .where(
              (item) =>
                  _searchQuery.isEmpty ||
                  item.itemName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();

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
      body:
          productProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productProvider.error != null
              ? Center(child: Text(productProvider.error!))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for products',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                  Expanded(
                    child:
                        items.isEmpty
                            ? const Center(child: Text('No products found'))
                            : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.7,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                // final isInWishlist = wishlist.isInWishlist(
                                //   item.id.toString(),
                                // );

                                final imgUrl = resolveImageUrl(item.image);

                                return GestureDetector(
                                  onTap: () {
                                    context.push(
                                      '/product/${item.name}',
                                      extra: item,
                                    );
                                  },
                                  child: Card(
                                    color: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ImageOrPlaceholder(
                                              imageUrl: imgUrl,
                                              fallbackText: item.itemName,
                                            ),
                                            // Positioned(
                                            //   top: 6,
                                            //   right: 6,
                                            //   child: IconButton(
                                            //     icon: Icon(
                                            //       Icons.favorite_border,
                                            //       // isInWishlist
                                            //       //     ? Icons.favorite
                                            //       //     : Icons.favorite_border,
                                            //       // color:
                                            //       //     isInWishlist
                                            //       //         ? Colors.red
                                            //       //         : Colors.black54,
                                            //     ),
                                            //     onPressed: () {
                                            //       ScaffoldMessenger.of(context)
                                            //         ..hideCurrentSnackBar()
                                            //         ..showSnackBar(
                                            //           const SnackBar(
                                            //             content: Text(
                                            //               'Wishlist functionality to be implemented',
                                            //             ),
                                            //           ),
                                            //         );
                                            //     },
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              Text(
                                                item.itemName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                              Text(
                                                item.category,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              AddToCartButton(
                                                item: CartItem(
                                                  code: item.name,
                                                  name: item.itemName,
                                                  price: item.itemPrice,
                                                  quantity: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Navigating to:${user?.userType} dashboard');
          context.go('/dashboard');
        },
        child: const Icon(Icons.dashboard, color: Colors.white),
      ),
    );
  }
}
