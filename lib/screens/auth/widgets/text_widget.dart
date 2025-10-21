import 'package:flutter/material.dart';

import '/core/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final TextInputAction txtInputAction;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.inputType = TextInputType.text,
    this.txtInputAction = TextInputAction.next,
    this.validator,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: inputType,
      textInputAction: txtInputAction,
      autofocus: autofocus,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: Icon(icon),
        hintText: hint,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
