import 'package:flutter/material.dart';
import 'package:ownashop/core/constants/colors.dart';

import '../../domain/item.dart';

class ItemTile extends StatelessWidget {
  final Item item;
  final VoidCallback onAddStock;

  const ItemTile({super.key, required this.item, required this.onAddStock});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      shadowColor: AppColors.accent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.itemName),
        subtitle: Text('Group: ${item.itemGroup}'),
        trailing: TextButton.icon(
          onPressed: onAddStock,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Stock', style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
