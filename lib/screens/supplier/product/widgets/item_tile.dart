import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/features/product/provider.dart';

import '/core/constants/colors.dart';
import '/core/utils/snackbar.dart';

class ProductTile extends StatefulWidget {
  final String name;
  final String itemName;
  final String category;

  const ProductTile({
    super.key,
    required this.name,
    required this.itemName,
    required this.category,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      title: Text(
        widget.itemName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.category,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.edit, color: AppColors.primary),
            onPressed:
                _isLoading
                    ? null
                    : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      final product = await context
                          .read<ProductProvider>()
                          .getProductByName(widget.name);

                      if (product != null && context.mounted) {
                        final shouldRefresh = await context.push<bool>(
                          '/edit-item/${widget.name}',
                          extra: product,
                        );

                        if (shouldRefresh == true && context.mounted) {
                          await context.read<ProductProvider>().fetchProducts();
                        }
                      }

                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
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
                    widget.name,
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
