import 'package:flutter/material.dart';

import '/shared/utils/doc_status.dart';

class StockEntryActions extends StatelessWidget {
  final DocStatus? docstatus;
  final Future<void> Function()? onSubmit;
  final Future<void> Function()? onCancel;
  final Future<void> Function()? onDelete;

  const StockEntryActions({
    super.key,
    this.docstatus,
    this.onSubmit,
    this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = docstatus ?? DocStatus.draft;

    final actionMap = {
      DocStatus.draft: _ActionConfig(
        label: "Submit",
        icon: Icons.check_circle,
        color: Colors.blue,
        callback: onSubmit,
      ),
      DocStatus.submitted: _ActionConfig(
        label: "Cancel",
        icon: Icons.cancel,
        color: Colors.red,
        callback: onCancel,
      ),
      DocStatus.cancelled: _ActionConfig(
        label: "Delete",
        icon: Icons.delete,
        color: Colors.red,
        callback: onDelete,
      ),
    };

    final config = actionMap[status];
    if (config?.callback == null) return const SizedBox.shrink();

    return ElevatedButton.icon(
      icon: Icon(config!.icon, color: Colors.white),
      label: Text(config.label),
      style: ElevatedButton.styleFrom(
        backgroundColor: config.color,
        foregroundColor: Colors.white,
      ),
      onPressed: () async => await config.callback?.call(),
    );
  }
}

class _ActionConfig {
  final String label;
  final IconData icon;
  final Color color;
  final Future<void> Function()? callback;

  const _ActionConfig({
    required this.label,
    required this.icon,
    required this.color,
    this.callback,
  });
}
