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
    return Theme(
      data: Theme.of(context).copyWith(
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8)),
          ),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: currentCode?.isEmpty ?? true ? null : currentCode,
        items:
            availableCodes.map((code) {
              return DropdownMenuItem<String>(
                value: code,
                child: SizedBox(
                  height: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        itemsMap[code] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        selectedItemBuilder: (context) {
          return availableCodes.map((code) {
            return Text(
              itemsMap[code] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          }).toList();
        },
        onChanged: availableCodes.isEmpty ? null : onChanged,
        decoration: InputDecoration(
          label: label ?? const Text('Item Name'), // 👈 supports required
          hintText: availableCodes.isEmpty ? 'All items selected' : null,
        ),
        validator: (val) {
          if (availableCodes.isEmpty) return null; // no items left
          return val == null || val.isEmpty ? 'Required' : null;
        },
        dropdownColor: Colors.white,
        menuMaxHeight: 300,
        isExpanded: true,
        alignment: AlignmentDirectional.topStart,
      ),
    );
  }
}
