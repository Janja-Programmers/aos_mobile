import 'package:flutter/material.dart';
import '/core/utils/snackbar.dart';
import 'package:provider/provider.dart';

import '/features/stock/providers/delete.dart';

Future<void> deleteStockEntry(BuildContext context, String id) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  );

  if (confirmed != true) return;

  final deleteProvider = context.read<DeleteStockEntryProvider>();
  await deleteProvider.deleteEntry(id);

  if (!context.mounted) return;

  if (deleteProvider.failure != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleteProvider.failure!.message),
        backgroundColor: Colors.red,
      ),
    );
  } else {
    // Show success message
    topSnackBar(
      context,
      'Stock entry deleted successfully.',
      type: TopSnackType.info,
    );
    // Go back and signal success to previous screen
    Navigator.pop(context, true);
  }
}
