import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/shared/widgets/app_bars.dart';
import '/shared/widgets/app_bottom_nav.dart';
import '/screens/auth/auth_provider.dart';
import '/features/website/prov.dart';
import '/features/website/slider_prov.dart';

import '../widgets/product_empty.dart';
import '../widgets/product_error.dart';
import '../widgets/product_loading.dart';
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
    final user = context.watch<AuthProvider>().user;

    return WillPopScope(
      onWillPop: () async {
        context.read<WebsiteItemProv>().clearProductDetail();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: TopAppBar(),
        bottomNavigationBar: const BottomNavBar(),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                // ----- SLIDER -----
                SliverToBoxAdapter(child: SliderCarousel()),

                // ----- LOADING / ERROR / EMPTY -----
                if (productProvider.isLoading)
                  const ProductsLoadingWidget()
                else if (productProvider.error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: ProductsErrorWidget(
                        message: productProvider.error!,
                        onRetry:
                            () => productProvider.searchItems(
                              productProvider.currentSearch,
                            ),
                      ),
                    ),
                  )
                else if (productProvider.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: ProductsEmptyWidget(onRetry: _onRefresh),
                    ),
                  )
                else ...[
                  // ----- SEARCH BAR -----
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for products',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      context
                                          .read<WebsiteItemProv>()
                                          .searchItems('');
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),

                  // ----- PRODUCT GRID -----
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = productProvider.items[index];
                        return ProductCard(item: item);
                      }, childCount: productProvider.items.length),
                    ),
                  ),

                  // ----- PAGINATION -----
                  if (!productProvider.isLoading &&
                      productProvider.items.isNotEmpty &&
                      productProvider.error == null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  productProvider.currentPage > 1
                                      ? productProvider.prevPage
                                      : null,
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                              ),
                              label: const Text('Prev'),
                            ),
                            Text(
                              "Page ${productProvider.currentPage}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed:
                                  productProvider.hasNext
                                      ? productProvider.nextPage
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
                    ),
                ],
              ],
            ),
          ),
        ),

        // ----- FAB FOR VENDORS -----
        floatingActionButton:
            user?.userType == "Vendor"
                ? FloatingActionButton(
                  onPressed: () => context.push('/dashboard'),
                  child: const Icon(Icons.dashboard, color: Colors.white),
                )
                : null,
      ),
    );
  }
}
