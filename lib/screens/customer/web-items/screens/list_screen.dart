import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/shared/widgets/app_bars.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/website/prov.dart';

import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';
  late ScrollController _scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WebsiteItemProv>().loadInitialItems();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value);
    });
  }

  List filteredItems(List items) {
    return items.where((item) {
      return _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _onScroll() {
    final provider = context.read<WebsiteItemProv>();

    if (!_scrollController.hasClients ||
        provider.isLoadingMore ||
        !provider.hasMore) {
      return;
    }

    final threshold = 300.0;
    final position = _scrollController.position;

    if (position.pixels + threshold >= position.maxScrollExtent) {
      provider.loadMoreItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<WebsiteItemProv>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final items = filteredItems(productProvider.items);

    return WillPopScope(
      onWillPop: () async {
        context.read<WebsiteItemProv>().clearProductDetail();
        return true; // allow pop
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: TopAppBar(),
        body:
            productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.error != null
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Oops! We ran into a problem."),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.read<WebsiteItemProv>().loadInitialItems();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
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
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh:
                            () =>
                                context
                                    .read<WebsiteItemProv>()
                                    .loadInitialItems(),
                        child:
                            items.isEmpty
                                ? const Center(child: Text('No products found'))
                                : Column(
                                  children: [
                                    Expanded(
                                      child: GridView.builder(
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
                                          return ProductCard(item: item);
                                        },
                                      ),
                                    ),
                                    if (productProvider.isLoadingMore)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: CircularProgressIndicator(),
                                      ),
                                  ],
                                ),
                      ),
                    ),
                  ],
                ),
        floatingActionButton:
            user?.userType == 'Vendor'
                ? FloatingActionButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Icon(Icons.dashboard, color: Colors.white),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
