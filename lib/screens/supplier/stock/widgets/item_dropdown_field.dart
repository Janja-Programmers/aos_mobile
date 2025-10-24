import 'package:flutter/material.dart';

class ItemDropdownField extends StatelessWidget {
  final String? currentCode;
  final Map<String, String> itemsMap;
  final List<String> availableCodes;
  final ValueChanged<String?> onChanged;
  final Widget? label;

  const ItemDropdownField({
    super.key,
    required this.currentCode,
    required this.itemsMap,
    required this.availableCodes,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ), // 👈 left-right margin
      child: Theme(
        data: theme.copyWith(
          dropdownMenuTheme: DropdownMenuThemeData(
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 6.0),
              ),
            ),
          ),
        ),
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          alignment: AlignmentDirectional.centerStart,
          dropdownColor: Colors.white,
          menuMaxHeight: 300, // 👈 makes list scrollable
          value:
              (currentCode != null && currentCode!.isNotEmpty)
                  ? currentCode
                  : null,
          onChanged: availableCodes.isEmpty ? null : onChanged,
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
            label:
                label ??
                const Text(
                  'Select Item',
                  style: TextStyle(color: Colors.black87),
                ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            hintText:
                availableCodes.isEmpty
                    ? 'No items available'
                    : 'Select an item',
          ),
          validator: (val) {
            if (availableCodes.isEmpty) return null; // skip validation
            if (val == null || val.isEmpty) {
              return 'Please select a product';
            }
            return null;
          },
        ),
      ),
    );
  }
}
