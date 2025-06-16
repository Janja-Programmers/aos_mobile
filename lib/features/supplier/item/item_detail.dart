import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../item/prov.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemName;

  const ItemDetailScreen({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    final item = context.watch<ItemProv>().getItemById(itemName);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Item Detail")),
        body: const Center(child: Text("Item not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(item.itemName ?? item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Code: ${item.itemCode}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text("Group: ${item.itemGroup}"),
            const SizedBox(height: 8),
            Text("Stock UOM: ${item.stockUom}"),
            const SizedBox(height: 8),
            Text("Status: ${item.disabled == 1 ? 'Disabled' : 'Enabled'}"),
            // Add more fields as you wish
          ],
        ),
      ),
    );
  }
}
