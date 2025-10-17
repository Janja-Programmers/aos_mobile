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
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WebsiteItemProv>().loadInitialItems();
      context.read<SliderProv>().loadSlider();
    });
  }

  @override
  void dispose() {
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
      final name = item.name ?? '';
      return _searchQuery.isEmpty ||
          name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: TopAppBar(),
        body: SafeArea(
          child:
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
                          onPressed:
                              () =>
                                  context
                                      .read<WebsiteItemProv>()
                                      .loadInitialItems(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh:
                        () =>
                            context.read<WebsiteItemProv>().loadInitialItems(),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SliderCarousel(),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              enabled:
                                  !productProvider.isLoading &&
                                  productProvider.items.isNotEmpty,
                              decoration: InputDecoration(
                                hintText:
                                    productProvider.isLoading
                                        ? 'Loading products...'
                                        : 'Search for products',
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

                          items.isEmpty
                              ? const Center(child: Text('No products found'))
                              : GridView.builder(
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
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return ProductCard(item: item);
                                },
                              ),
                          if (productProvider.error == null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Prev button
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
                                  // Page indicator
                                  Text(
                                    'Page ${productProvider.currentPage}',
                                    // 'Page ${productProvider.currentPage} of ${productProvider.totalPages}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Next button
                                  ElevatedButton.icon(
                                    onPressed:
                                        productProvider.hasMore
                                            ? () => productProvider.nextPage()
                                            : null,
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
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
