import 'package:flutter/material.dart';

import '../utils/doc_status.dart';

class DocstatusChip extends StatelessWidget {
  final DocStatus docstatus;

  const DocstatusChip({super.key, required this.docstatus});

  Color get statusColor {
    switch (docstatus) {
      case DocStatus.draft:
        return Colors.grey;
      case DocStatus.submitted:
        return Colors.blue;
      case DocStatus.cancelled:
        return const Color.fromARGB(255, 215, 116, 109);
    }
  }

  String get statusLabel {
    switch (docstatus) {
      case DocStatus.draft:
        return 'Draft';
      case DocStatus.submitted:
        return 'Submitted';
      case DocStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        statusLabel,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: statusColor,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
