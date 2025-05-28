import 'package:flutter/material.dart';

class ItemGroupDropdown extends StatelessWidget {
  final String selectedGroup;
  final Function(String) onChanged;

  const ItemGroupDropdown({
    super.key,
    required this.selectedGroup,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const groups = [
      'Electronics',
      'Fashion',
      'Groceries',
      'Books',
      'Furniture',
    ];

    return DropdownButtonFormField<String>(
      value: selectedGroup.isEmpty ? null : selectedGroup,
      decoration: const InputDecoration(
        labelText: 'Item Group',
        border: OutlineInputBorder(),
      ),
      items:
          groups.map((group) {
            return DropdownMenuItem(value: group, child: Text(group));
          }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
