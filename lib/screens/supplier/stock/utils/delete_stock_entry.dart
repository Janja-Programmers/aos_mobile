import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/utils/snackbar.dart';
import 'package:provider/provider.dart';

import '/features/stock/providers/delete.dart';

Future<bool?> deleteStockEntry(BuildContext context, String id) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  );

  if (confirmed != true) return false;

  final deleteProvider = context.read<DeleteStockEntryProvider>();
  await deleteProvider.deleteEntry(id);

  if (!context.mounted) return false;

  if (deleteProvider.failure != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleteProvider.failure!.message),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  } else {
    topSnackBar(
      context,
      'Stock entry deleted successfully.',
      type: TopSnackType.info,
    );
    context.pop(true);
    return true;
  }
}
