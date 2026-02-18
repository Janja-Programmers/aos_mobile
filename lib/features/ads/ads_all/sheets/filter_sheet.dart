import 'package:flutter/material.dart';

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) {
      return const _FilterSheet();
    },
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text('Filters coming soon'),
    );
  }
}
