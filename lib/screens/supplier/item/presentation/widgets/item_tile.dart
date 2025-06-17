import 'package:flutter/material.dart';
import 'package:ownashop/core/constants/colors.dart';

import '../../../../../features/item/domain/entity.dart';

class ItemTile extends StatelessWidget {
  final Item item;

  const ItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      shadowColor: AppColors.accent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('Group: ${item.itemGroup}'),
        trailing: TextButton.icon(
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Stock', style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
