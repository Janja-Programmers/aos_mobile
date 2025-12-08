import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/shared/widgets/app_bars.dart';
import '/screens/auth/auth_provider.dart';
import '/features/website/prov.dart';
import '/features/website/slider_prov.dart';

import '../widgets/product_card.dart';
import '../widgets/slider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WebsiteItemProv>().searchItems('');
      context.read<SliderProv>().loadSlider();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<WebsiteItemProv>().searchItems(value);
    });
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    await context.read<WebsiteItemProv>().searchItems('');
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<WebsiteItemProv>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return WillPopScope(
      onWillPop: () async {
        context.read<WebsiteItemProv>().clearProductDetail();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: TopAppBar(),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SliderCarousel(),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _searchController,
                      enabled: true,
                      decoration: InputDecoration(
                        hintText: 'Search for products',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<WebsiteItemProv>().searchItems(
                                      '',
                                    );
                                  },
                                )
                                : null,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),

                  // Loading / Error / Empty States
                  if (productProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (productProvider.error != null)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(productProvider.error!),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed:
                                () => productProvider.searchItems(
                                  productProvider.currentSearch,
                                ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (productProvider.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          productProvider.currentSearch.isEmpty
                              ? 'No products available'
                              : 'No products found for "${productProvider.currentSearch}"',
                        ),
                      ),
                    )
                  else
                    // Product Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: productProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = productProvider.items[index];
                        return ProductCard(item: item);
                      },
                    ),

                  // Pagination Controls
                  if (productProvider.items.isNotEmpty &&
                      productProvider.error == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                productProvider.currentPage > 1
                                    ? () => productProvider.prevPage()
                                    : null,
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                            ),
                            label: const Text('Prev'),
                          ),
                          Text(
                            'Page ${productProvider.currentPage}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                productProvider.hasMore
                                    ? () => productProvider.nextPage()
                                    : null,
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            label: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton:
            user?.userType == 'Vendor'
                ? FloatingActionButton(
                  onPressed: () => context.push('/dashboard'),
                  child: const Icon(Icons.dashboard, color: Colors.white),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
