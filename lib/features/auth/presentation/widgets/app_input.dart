import 'package:flutter/material.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool obscure;
  final VoidCallback? toggle;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const AppInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.obscure = false,
    this.toggle,
    this.validator,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscure,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        prefixIcon: Icon(icon),
        suffixIcon:
            isPassword
                ? GestureDetector(
                  onTap: toggle,
                  child: Text(
                    obscure ? "Show" : "Hide",
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
                : null,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      textInputAction: textInputAction,
    );
  }
}
