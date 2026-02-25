import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    this.label,
    this.value,
    this.required = false,
    this.leading,
    this.trailing,
    this.placeholder = 'Select',
    this.onTap,
  });

  final String? label;
  final String? value;
  final bool required;
  final Widget? leading;
  final Widget? trailing;
  final String placeholder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final showValue = value != null && value!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colors.border,
        ),
        child: Row(
          children: [
            // Leading icon (primary color)
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(color: colors.primary, size: 22),
                child: leading!,
              ),
              const SizedBox(width: 12),
            ],

            // Value / Placeholder
            Expanded(
              child: Text(
                showValue ? value! : placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.p.copyWith(
                  color: showValue ? colors.textPrimary : colors.textMuted,
                  fontWeight: showValue ? FontWeight.w500 : null,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: colors.textPrimary,
                ),
          ],
        ),
      ),
    );
  }
}
