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
      return ElevatedButton.icon(
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text("Submit"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        onPressed: onSubmit,
      );
    }

    if (docstatus == DocStatus.submitted && onCancel != null) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.cancel, color: Colors.white),
        label: const Text("Cancel"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: onCancel,
      );
    }

    if (docstatus == DocStatus.cancelled && onDelete != null) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.delete, color: Colors.white),
        label: const Text("Delete"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
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
