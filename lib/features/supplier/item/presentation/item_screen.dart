import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/main_bar.dart';
import '../../website/add_website_item_screen.dart';

import '../../../auth/presentation/auth_provider.dart';

import '../../../item/prov.dart';

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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProv>().loadItems();
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
    final itemProvider = context.watch<ItemProv>();

    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user?.username;

    final items =
        itemProvider.items.where((item) => item.owner == user).toList();

    final query = _searchController.text.trim().toLowerCase();
    final filteredItems =
        items.where((item) {
          return query.isEmpty || item.name.toLowerCase().contains(query);
        }).toList();

    Widget content;

    if (itemProvider.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (itemProvider.error != null) {
      content = Center(
        child: Text(
          'Error: ${itemProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (itemProvider.items.isEmpty) {
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemNameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _itemGroupController,
                          decoration: const InputDecoration(
                            labelText: 'Item Group',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search...',
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
                Text("${filteredItems.length} of ${filteredItems.length}"),
              ],
            ),
          ),

          const Divider(),

          // Item List
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  onTap: () {
                    context.go('/item-detail/${item.name}');
                  },
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          item.disabled == 1
                              ? Colors.grey[300]
                              : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.disabled == 0 ? "Enabled" : "Disabled",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return MainBarScaffold(
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
      scaffoldKey: _scaffoldKey,
      subTitle: "Items",
      actionButton: CustomButton(
        label: "Create New",
        pageBuilder: () => const AddWebsiteItemScreen(),
      ),
      body: content,
    );
  }
}
