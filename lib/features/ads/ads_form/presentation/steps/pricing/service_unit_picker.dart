import 'package:flutter/material.dart';

class ServiceUnitPicker extends StatelessWidget {
  const ServiceUnitPicker({
    super.key,
    required this.units,
    required this.selected,
    required this.onChanged,
  });

  final List<String> units;
  final String? selected;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: const InputDecoration(labelText: 'Price Unit'),
      items: units
          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
