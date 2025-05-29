import 'package:flutter/material.dart';

import '../../domain/item.dart';

class ItemTile extends StatelessWidget {
  final Item item;
  final VoidCallback onAddStock;

  const ItemTile({super.key, required this.item, required this.onAddStock});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.itemName),
        subtitle: Text('Group: ${item.itemGroup}'),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: onAddStock,
        ),
      ),
    );
  }
}
