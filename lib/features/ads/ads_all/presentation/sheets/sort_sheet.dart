import 'package:flutter/material.dart';

Future<void> showSortSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) {
      return const _SortSheet();
    },
  );
}

class _SortSheet extends StatelessWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: Text('Best Match')),
        ListTile(title: Text('Price: Low → High')),
        ListTile(title: Text('Newest')),
      ],
    );
  }
}
