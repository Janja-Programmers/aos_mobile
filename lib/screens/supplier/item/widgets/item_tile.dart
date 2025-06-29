import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/features/product/domain/product.dart';

import '/core/constants/colors.dart';

class ItemTile extends StatelessWidget {
  final Product product;

  const ItemTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      shadowColor: AppColors.accent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(product.itemName),
        subtitle: Text(product.category),
        trailing: TextButton.icon(
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Edit', style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            context.go('/item-detail/${product.itemName}');
          },
        ),
      ),
    );
  }
}
