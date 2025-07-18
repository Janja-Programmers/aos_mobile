import 'package:flutter/material.dart';

class DocstatusChip extends StatelessWidget {
  final int docstatus;

  const DocstatusChip({super.key, required this.docstatus});

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return const Color.fromARGB(255, 215, 116, 109);
      default:
        return Colors.orange;
    }
  }

  String getStatusLabel(int status) {
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Submitted';
      case 2:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        getStatusLabel(docstatus),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: getStatusColor(docstatus),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
