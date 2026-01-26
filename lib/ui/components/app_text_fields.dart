import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).inputDecorationTheme;

    // Use Theme's InputDecorationTheme, override only what you need.
    final decoration = InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
    ).applyDefaults(base);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: decoration,
      onChanged: onChanged,
    );
  }
}
