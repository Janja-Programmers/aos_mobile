import 'package:flutter/material.dart';

class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    this.value,
    this.required = false,
    this.leading,
    this.onTap,
  });

  final String label;
  final String? value;
  final bool required;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).inputDecorationTheme;
    final textTheme = Theme.of(context).textTheme;
    final showValue = value != null && value!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: leading,
          suffixIcon: const Icon(Icons.chevron_right_rounded),
        ).applyDefaults(base),
        child: Text(
          showValue ? value! : 'Select',
          style: showValue
              ? textTheme.bodyMedium
              : textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}
