import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/build_subtitle.dart';
import '/shared/widgets/custom_button.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/error_state.dart';

import '/features/product/provider.dart';

import 'widgets/item_tile.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemGroupController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  Future<void> _refresh() async {
    await context.read<ProductProvider>().fetchProducts();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemGroupController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final products = productProvider.products;

    final query = _searchController.text.trim().toLowerCase();
    final filteredproducts =
        products.where((product) {
          return query.isEmpty ||
              product.itemName.toLowerCase().contains(query);
        }).toList();

    Widget content;

    if (productProvider.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (productProvider.error != null) {
      content = ErrorState(
        resource: 'products',
        actionLabel: 'Retry',
        onAction: _refresh,
      );
    } else if (productProvider.products.isEmpty) {
      content = EmptyState(message: 'No products found');
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + Filter Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search products by name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          Expanded(
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // List Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Item Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${filteredproducts.length} of ${products.length}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 0,
                    thickness: 1.2,
                    color: AppColors.background,
                  ),

                  // List or empty placeholder inside the Card
                  Expanded(
                    child:
                        filteredproducts.isEmpty
                            ? EmptyState(
                              message: 'No products match your search.',
                              actionLabel: 'Clear search',
                              onAction: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                            : RefreshIndicator(
                              onRefresh: () async {
                                await context
                                    .read<ProductProvider>()
                                    .fetchProducts();
                              },
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: filteredproducts.length,
                                separatorBuilder:
                                    (_, _) => const Divider(
                                      height: 0.5,
                                      thickness: 0.5,
                                    ),
                                itemBuilder: (context, index) {
                                  final product = filteredproducts[index];
                                  return ProductTile(
                                    name: product.name,
                                    itemName: product.itemName,
                                    category: product.category,
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 1, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: buildSubTitle(title: 'Products'),
      actionButton: CustomButton(
        onPressed: () async {
          final result = await context.push<bool>('/add-item');
          if (result == true && context.mounted) {
            await context.read<ProductProvider>().fetchProducts();
          }
        },
      ),

      body: content,
    );
  }
}
