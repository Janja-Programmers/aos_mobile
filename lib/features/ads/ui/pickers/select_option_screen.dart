import 'package:flutter/material.dart';

class SelectOptionScreen extends StatelessWidget {
  const SelectOptionScreen({
    super.key,
    required this.title,
    required this.options,
    this.selected,
    this.multi = false,
  });

  final String title;
  final List<String> options;
  final dynamic selected;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedSet = multi
        ? <String>{
            ...(selected is List
                ? (selected as List).map((e) => e.toString())
                : const <String>[]),
          }
        : <String>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      ),
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final opt = options[i];
          final isSel = multi
              ? selectedSet.contains(opt)
              : selected?.toString() == opt;
          return ListTile(
            title: Text(opt),
            trailing: isSel ? Icon(Icons.check, color: scheme.primary) : null,
            onTap: () {
              if (!multi) {
                Navigator.of(context).pop(opt);
                return;
              }
              final next = Set<String>.from(selectedSet);
              if (next.contains(opt)) {
                next.remove(opt);
              } else {
                next.add(opt);
              }
              Navigator.of(context).pop(next.toList());
            },
          );
        },
      ),
    );
  }
}
