import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: readOnly ? null : onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        fillColor: readOnly ? Colors.grey.shade100 : null,
        filled: readOnly,
      ),
      validator:
          isRequired
              ? (val) => val == null || val.trim().isEmpty ? 'Required' : null
              : null,
    );
  }
}
