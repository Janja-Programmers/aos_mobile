import 'package:flutter/material.dart';

class StockEntryActions extends StatelessWidget {
  final int? docstatus;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final VoidCallback? onReload;
  final VoidCallback? onPrint;

  const StockEntryActions({
    super.key,
    this.docstatus,
    this.onSubmit,
    this.onCancel,
    this.onReload,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      if (onSubmit != null && docstatus == 0)
        _MenuItem('submit', 'Submit', Colors.green),
      if (onCancel != null && docstatus == 1)
        _MenuItem('cancel', 'Cancel', Colors.red),
      if (onReload != null) _MenuItem('reload', 'Reload', Colors.blue),
      if (onPrint != null) _MenuItem('print', 'Print', Colors.orange),
    ];

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
        }
      },
      itemBuilder:
          (context) =>
              items.map((item) {
                return PopupMenuItem<String>(
                  value: item.value,
                  child: Text(item.label, style: TextStyle(color: item.color)),
                );
              }).toList(),
    );
  }
}

class _MenuItem {
  final String value;
  final String label;
  final Color color;

  _MenuItem(this.value, this.label, this.color);
}
