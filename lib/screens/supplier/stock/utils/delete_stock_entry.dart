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
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
  );

  if (confirmed != true) return false;

  final deleteProvider = context.read<DeleteStockEntryProvider>();
  await deleteProvider.deleteEntry(id);

  if (!context.mounted) return false;

  if (deleteProvider.failure != null) {
    topSnackBar(
      context,
      'Unable to delete Stock entry.',
      type: TopSnackType.error,
    );
    return false;
  } else {
    topSnackBar(
      context,
      'Stock entry deleted successfully.',
      type: TopSnackType.success,
    );
    context.pop(true);
    return true;
  }
}
