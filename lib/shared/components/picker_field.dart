import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    this.label,
    this.value,
    this.required = false,
    this.leading,
    this.trailing,
    this.placeholder = 'Select',
    this.helperText,
    this.onTap,
  });

  final String? label;
  final String? value;
  final bool required;
  final Widget? leading;
  final Widget? trailing;
  final String placeholder;
  final String? helperText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final showValue = value != null && value!.trim().isNotEmpty;
    final effectiveLabel = label?.trim();
    final effectiveHelper = helperText?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (effectiveLabel != null && effectiveLabel.isNotEmpty) ...[
          Text(
            required ? '$effectiveLabel *' : effectiveLabel,
            style: context.pStrong,
          ),
          if (effectiveHelper != null && effectiveHelper.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(effectiveHelper, style: context.pMuted),
          ],
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: BoxBorder.all(color: colors.border),
              color: colors.surface,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  IconTheme(
                    data: IconThemeData(color: colors.primary, size: 22),
                    child: leading!,
                  ),
                  const SizedBox(width: 12),
                ],
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
        ),
      ],
    );
  }
}
