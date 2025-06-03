import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../website/presentation/web_item_provider.dart';

import '../../wishlist/presentation/wishlist_provider.dart';

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
      context.read<WebsiteItemProvider>().loadAllWebsiteItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<WebsiteItemProvider>();
    final wishlist = context.watch<WishlistProvider>();

    final items =
        itemProvider.websiteItems
            .where((item) => item.isPublished == true)
            .where(
              (item) =>
                  _searchQuery.isEmpty ||
                  item.websiteDisplayName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png'),
        ),
        title: const Text('Own A Shop'),
        actions: [
          TextButton(
            onPressed: () => context.push('/login'),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body:
          itemProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : itemProvider.error != null
              ? Center(child: Text(itemProvider.error!))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for products',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                                final isInWishlist = wishlist.isInWishlist(
                                  item.id.toString(),
                                );

                                final firstImage =
                                    item.images.isNotEmpty
                                        ? item.images.first
                                        : null;

                                return GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Product Detail Later"),
                                      ),
                                    );
                                  },

                                  child: Card(
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
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      12,
                                                    ),
                                                    topRight: Radius.circular(
                                                      12,
                                                    ),
                                                  ),
                                              child: FutureBuilder<bool>(
                                                future:
                                                    firstImage != null
                                                        ? File(
                                                          firstImage,
                                                        ).exists()
                                                        : Future.value(false),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState !=
                                                          ConnectionState
                                                              .done ||
                                                      !(snapshot.data ??
                                                          false)) {
                                                    // Show placeholder with item initial
                                                    return Container(
                                                      width: double.infinity,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            const BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                              topRight:
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        item
                                                                .websiteDisplayName
                                                                .isNotEmpty
                                                            ? item
                                                                .websiteDisplayName[0]
                                                                .toUpperCase()
                                                            : '?',
                                                        style: const TextStyle(
                                                          fontSize: 48,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Image exists
                                                    return ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                  12,
                                                                ),
                                                            topRight:
                                                                Radius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                      child: Image.file(
                                                        File(firstImage!),
                                                        width: double.infinity,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: IconButton(
                                                icon: Icon(
                                                  isInWishlist
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color:
                                                      isInWishlist
                                                          ? Colors.red
                                                          : Colors.black54,
                                                ),
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context)
                                                    ..hideCurrentSnackBar()
                                                    ..showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Wishlist functionality to be implemented',
                                                        ),
                                                      ),
                                                    );
                                                },
                                              ),
                                            ),
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
                                                item.websiteDisplayName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'No Group',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context)
                                                    ..hideCurrentSnackBar()
                                                    ..showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Add to cart functionality to be implemented',
                                                        ),
                                                      ),
                                                    );
                                                },
                                                icon: const Icon(
                                                  Icons.shopping_cart,
                                                ),
                                                label: const Text(
                                                  'Add to cart',
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
    );
  }
}
