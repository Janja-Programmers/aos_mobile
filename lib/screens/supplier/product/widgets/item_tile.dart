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
  final VoidCallback? onDeleted;

  const ProductTile({
    super.key,
    required this.name,
    required this.itemName,
    required this.category,
    this.onDeleted,
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.delete, color: Colors.red),
            onPressed:
                _isLoading
                    ? null
                    : () async {
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
                                  onPressed: () => context.pop(false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () => context.pop(true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                      );

                      if (confirm != true || !mounted) return;

                      setState(() => _isLoading = true);

                      try {
                        await context.read<ProductProvider>().deleteProduct(
                          widget.name,
                        );

                        // ✅ Show snackbar immediately after successful deletion
                        if (mounted) {
                          topSnackBar(
                            context,
                            'Deleted successfully',
                            type: TopSnackType.success,
                          );
                        }

                        // Refresh list after showing snackbar
                        if (mounted) {
                          await context.read<ProductProvider>().fetchProducts();
                        }
                      } catch (e) {
                        if (mounted) {
                          topSnackBar(
                            context,
                            'This product is linked to stock records and cannot be deleted. Cancel stock intake entry first.',
                            type: TopSnackType.error,
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
          ),
        ],
      ),
    );
  }
}
