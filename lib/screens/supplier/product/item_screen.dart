import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import '/shared/widgets/custom_button.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/product/provider.dart';

import 'add_product_screen.dart';
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
      final user = context.read<AuthProvider>().user?.username;
      context.read<ProductProvider>().fetchVendorProducts(user!);
    });
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
      content = Center(
        child: Text(
          'Error: ${productProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (productProvider.products.isEmpty) {
      content = const Center(child: Text('No items found.'));
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + Filter Section
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search items by name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                const Text("Item Name"),
                const Spacer(),
                Text(
                  "${filteredproducts.length} of ${filteredproducts.length}",
                ),
              ],
            ),
          ),

          // Item List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final user = context.read<AuthProvider>().user?.username;
                if (user != null) {
                  await context.read<ProductProvider>().fetchVendorProducts(
                    user,
                  );
                }
              },
              child: ListView.builder(
                itemCount: filteredproducts.length,
                itemBuilder: (context, index) {
                  final product = filteredproducts[index];
                  return ItemTile(product: product);
                },
              ),
            ),
          ),
        ],
      );
    }

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 1, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: "Items",
      actionButton: CustomButton(pageBuilder: () => AddProductScreen()),
      body: content,
    );
  }
}
