import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/features/product/provider.dart';
import '/features/product/domain/product.dart';
import '/core/constants/colors.dart';
import '/core/utils/snackbar.dart';

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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () {
                context.push('/edit-item/${product.name}', extra: product);
              },
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Delete Product"),
                        content: const Text(
                          "Are you sure you want to delete this product?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  try {
                    await context.read<ProductProvider>().deleteProduct(
                      product.name,
                    );
                    if (context.mounted) {
                      topSnackBar(context, '✅ Deleted successfully');
                    }
                    final productProvider = context.read<ProductProvider>();
                    await productProvider.fetchProducts();
                    return;
                  } catch (e) {
                    if (context.mounted) {
                      topSnackBar(context, '❌ Error: $e');
                    }
                    return;
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
