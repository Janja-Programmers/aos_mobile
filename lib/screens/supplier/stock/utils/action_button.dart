import 'package:flutter/material.dart';

class StockEntryActions extends StatelessWidget {
  final int docstatus;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const StockEntryActions({
    super.key,
    required this.docstatus,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (docstatus == 0) {
      return TextButton.icon(
        onPressed: onSubmit,
        icon: const Icon(Icons.send),
        label: const Text('Submit'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green[700],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );
    }

    if (docstatus == 1) {
      return TextButton.icon(
        onPressed: onCancel,
        icon: const Icon(Icons.cancel),
        label: const Text('Cancel'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red[700],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
