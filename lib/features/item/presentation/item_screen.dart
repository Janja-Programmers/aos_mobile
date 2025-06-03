import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../stock/presentation/stock_entry_form_screen.dart';
import 'item_provider.dart';
import 'widgets/add_item_form.dart';
import 'widgets/item_tile.dart';

class ItemScreen extends StatelessWidget {
  final int userId;

  const ItemScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              provider.fetchItems(userId);
            },
          ),
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder:
                    (_) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: AddItemForm(
                        userId: userId,
                        onSubmit: (newItem) => provider.addItem(newItem),
                      ),
                    ),
              );
            },
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            label: Text("Add item", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: provider.items.length,
                itemBuilder:
                    (_, i) => ItemTile(
                      item: provider.items[i],
                      onAddStock: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StockEntryFormScreen(),
                          ),
                        );
                      },
                    ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder:
                (_) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: AddItemForm(
                    userId: userId,
                    onSubmit: (newItem) => provider.addItem(newItem),
                  ),
                ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
