import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onDisabledTap,
    this.disabledBorderColor,
    this.disabledTextColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onDisabledTap;
  final Color? disabledBorderColor;
  final Color? disabledTextColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final isDisabled = onPressed == null || loading;

    // Active (filled)
    final activeBg = backgroundColor ?? colors.primary;
    final activeFg = textColor ?? colors.textPrimary;

    // Disabled (outlined)
    final disBorder = disabledBorderColor ?? colors.textPrimary;
    final disFg = disabledTextColor ?? colors.textPrimary;

    final bgColor = isDisabled ? Colors.transparent : activeBg;
    final fgColor = isDisabled ? disFg : activeFg;

    // If disabled but we want a tap action, we can't rely on ElevatedButton's disabled state.
    final effectiveOnPressed = isDisabled ? (onDisabledTap) : onPressed;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isDisabled
                ? BorderSide(color: disBorder, width: 1.2)
                : BorderSide.none,
          ),
        ),
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(fgColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fgColor),
                    const SizedBox(width: 8),
                  ],
                  Text(text, style: context.p.copyWith(color: fgColor)),
                ],
              ),
      ),
    );
  }
}
