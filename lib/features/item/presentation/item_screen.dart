import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'prov.dart';
import 'widgets/item_tile.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger item load
    Future.microtask(() {
      final provider = Provider.of<ItemProv>(context, listen: false);
      provider.getAllItems(); // or provider.loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemProv>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              provider.getAllItems(); // or provider.loadItems();
            },
          ),
        ],
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.items.isEmpty
              ? const Center(child: Text('No items found.'))
              : ListView.builder(
                itemCount: provider.items.length,
                itemBuilder: (_, i) => ItemTile(item: provider.items[i]),
              ),
    );
  }
}
