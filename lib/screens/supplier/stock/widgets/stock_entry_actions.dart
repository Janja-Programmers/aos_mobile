import 'package:flutter/material.dart';

class StockEntryActions extends StatelessWidget {
  final int? docstatus;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const StockEntryActions({
    super.key,
    this.docstatus,
    this.onSubmit,
    this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (docstatus == DocStatus.draft && onSubmit != null) {
      return IconButton(
        icon: const Icon(Icons.check_circle, color: Colors.green),
        tooltip: 'Submit',
        onPressed: onSubmit,
      );
    }

    if (docstatus == DocStatus.submitted && onCancel != null) {
      return IconButton(
        icon: const Icon(Icons.cancel, color: Colors.red),
        tooltip: 'Cancel',
        onPressed: onCancel,
      );
    }

    if (docstatus == DocStatus.cancelled && onDelete != null) {
      return IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        tooltip: 'Delete',
        onPressed: onDelete,
      );
    }

    return const SizedBox.shrink();
  }
}

class DocStatus {
  static const int draft = 0;
  static const int submitted = 1;
  static const int cancelled = 2;
}
