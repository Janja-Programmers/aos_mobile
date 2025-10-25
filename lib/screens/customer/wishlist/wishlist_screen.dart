import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/features/wishlist/provider.dart';

import '/shared/widgets/app_bars.dart';

import 'widgets/wishlist_item_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _searchQuery = '';
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Future.microtask(() {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  List filteredItems(List items) {
    return items.where((item) {
      return _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishlistProvider>();
    final items = filteredItems(provider.items);

    return Scaffold(
      appBar: TopAppBar(),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search your wishlist',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => provider.loadWishlist(),
                      child:
                          items.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.heart_broken,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Your wishlist is empty.',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () => context.push('/'),
                                      child: const Text(
                                        'Start Shopping',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : GridView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 0.65,
                                    ),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return WishlistItemCard(
                                    item: item,
                                    onRemove: () => provider.remove(item.id),
                                    onTap:
                                        () =>
                                            context.push('/product/${item.id}'),
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              ),
    );
  }
}
