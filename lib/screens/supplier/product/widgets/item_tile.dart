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
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      title: Text(
        product.itemName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        product.category,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              final shouldRefresh = await context.push<bool>(
                '/edit-item/${product.name}',
                extra: product,
              );

              if (shouldRefresh == true && context.mounted) {
                await context.read<ProductProvider>().fetchProducts();
              }
            },
          ),
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
                    topSnackBar(context, 'Deleted successfully');
                    await context.read<ProductProvider>().fetchProducts();
                  }
                } catch (e) {
                  if (context.mounted) {
                    topSnackBar(
                      context,
                      'Error: Unable to delete product',
                      type: TopSnackType.error,
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
