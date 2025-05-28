import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../item_provider.dart';
import '../widgets/confirm_delete_dialog.dart';
import 'create_item_screen.dart';
import 'edit_item_screen.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ItemProvider>(context, listen: false).loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              itemProvider.loadItems();
            },
          ),
        ],
      ),
      body:
          itemProvider.items.isEmpty
              ? const Center(child: Text('No items found.'))
              : ListView.builder(
                itemCount: itemProvider.items.length,
                itemBuilder: (context, index) {
                  final item = itemProvider.items[index];
                  return ListTile(
                    title: Text(item.itemName),
                    subtitle: Text('Group: ${item.itemGroup}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditItemScreen(item: item),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showConfirmDeleteDialog(
                              context,
                              item.itemName,
                            );
                            if (confirm == true) {
                              await itemProvider.deleteItem(item.itemName);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item deleted')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
