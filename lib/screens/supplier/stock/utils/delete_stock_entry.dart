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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'Permanently delete stock intake?',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => context.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Yes, Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
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
      'Stock intake deleted successfully.',
      type: TopSnackType.success,
    );
    context.pop(true);
    return true;
  }
}
