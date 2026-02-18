import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

class CategoryPills extends StatelessWidget {
  const CategoryPills({
    super.key,
    required this.children,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CategoryNode> children;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: children.length + 1,
        itemBuilder: (context, i) {
          final isAll = i == 0;

          final id = isAll ? null : children[i - 1].id;
          final label = isAll ? 'All' : children[i - 1].name;

          final selected = id == selectedId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => onSelect(id),
            ),
          );
        },
      ),
    );
  }
}
