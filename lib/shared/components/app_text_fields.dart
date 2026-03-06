import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

/// Shared app text inputs that rely on the app's [InputDecorationTheme].
///
/// Use [AppFormField] for forms (validation) and [AppTextField] for simple inputs.
/// Use [AppPasswordFormField] for password inputs with built-in visibility toggle.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.enabled,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).inputDecorationTheme;

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
      enabled: enabled,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
    );
  }
}

class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled,
    this.textInputAction,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).inputDecorationTheme;

    final decoration = InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
    ).applyDefaults(base);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: decoration,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
    );
  }
}

class AppPasswordFormField extends StatefulWidget {
  const AppPasswordFormField({
    super.key,
    this.controller,
    this.label,
    this.validator,
    this.onFieldSubmitted,
    this.enabled,
    this.textInputAction,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? label;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<AppPasswordFormField> createState() => _AppPasswordFormFieldState();
}

class _AppPasswordFormFieldState extends State<AppPasswordFormField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      controller: widget.controller,
      label: widget.label ?? '',
      obscureText: _obscure,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: context.appColors.primary,
        ),
      ),
    );
  }
}
