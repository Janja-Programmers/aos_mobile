import 'package:flutter/material.dart';

Future<bool?> showConfirmDeleteDialog(BuildContext context, String itemName) {
  return showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
  );
}
