import 'package:flutter/material.dart';

class StockEntryActions extends StatelessWidget {
  final int? docstatus;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final VoidCallback? onReload;
  final VoidCallback? onPrint;
  final VoidCallback? onDelete;

  const StockEntryActions({
    super.key,
    this.docstatus,
    this.onSubmit,
    this.onCancel,
    this.onReload,
    this.onPrint,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      if (onSubmit != null && docstatus == DocStatus.draft)
        _MenuItem('submit', 'Submit', Colors.green),

      if (onCancel != null && docstatus == DocStatus.submitted)
        _MenuItem('cancel', 'Cancel', Colors.red),

      if (onReload != null) _MenuItem('reload', 'Reload', Colors.blue),

      if (onPrint != null && docstatus == DocStatus.submitted)
        _MenuItem('print', 'Print', Colors.orange),

      if (onDelete != null && docstatus == DocStatus.cancelled)
        _MenuItem('delete', 'Delete', Colors.red),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'submit':
            onSubmit?.call();
            break;
          case 'cancel':
            onCancel?.call();
            break;
          case 'reload':
            onReload?.call();
            break;
          case 'print':
            onPrint?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) {
        return items
            .map(
              (item) => PopupMenuItem<String>(
                value: item.value,
                child: Text(item.label, style: TextStyle(color: item.color)),
              ),
            )
            .toList();
      },
    );
  }
}

class _MenuItem {
  final String value;
  final String label;
  final Color color;

  _MenuItem(this.value, this.label, this.color);
}

class DocStatus {
  static const int draft = 0;
  static const int submitted = 1;
  static const int cancelled = 2;
}
