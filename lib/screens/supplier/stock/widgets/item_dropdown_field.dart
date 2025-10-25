import 'package:flutter/material.dart';

class ItemDropdownField extends StatelessWidget {
  final String? currentCode;
  final Map<String, String> itemsMap;
  final List<String> availableCodes;
  final ValueChanged<String?>? onChanged;
  final String label;
  final bool isRequired;
  final bool readOnly;
  final String? Function(String?)? validator;

  const ItemDropdownField({
    super.key,
    required this.currentCode,
    required this.itemsMap,
    required this.availableCodes,
    this.onChanged,
    required this.label,
    this.isRequired = false,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyLarge?.copyWith(
      color: Colors.grey[700],
    );

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value:
          (currentCode != null && currentCode!.isNotEmpty) ? currentCode : null,
      onChanged: readOnly ? null : onChanged,
      items:
          availableCodes.map((code) {
            return DropdownMenuItem<String>(
              value: code,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  itemsMap[code] ?? code,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            );
          }).toList(),
      selectedItemBuilder: (context) {
        return availableCodes.map((code) {
          return Text(
            itemsMap[code] ?? code,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: label,
            style: labelStyle,
            children:
                isRequired
                    ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                    : [],
          ),
        ),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        hintText:
            availableCodes.isEmpty ? 'No items available' : 'Select an item',
      ),
      dropdownColor: Colors.white,
      menuMaxHeight: 300,
      validator: (val) {
        if (validator != null) return validator!(val);
        if (availableCodes.isEmpty) return null;
        if (val == null || val.isEmpty) return 'Please select a product';
        return null;
      },
    );
  }
}
