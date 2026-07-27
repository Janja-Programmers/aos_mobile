import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

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
    final activeBackground = backgroundColor ?? colors.primary;
    final activeForeground = textColor ?? colors.white;
    final disabledBorder = disabledBorderColor ?? colors.textPrimary;
    final disabledForeground = disabledTextColor ?? colors.textPrimary;
    final background = isDisabled ? colors.surface : activeBackground;
    final foreground = isDisabled ? disabledForeground : activeForeground;
    final effectiveOnPressed = isDisabled ? onDisabledTap : onPressed;

    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: background,
            foregroundColor: foreground,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: isDisabled
                  ? BorderSide(color: disabledBorder, width: 1.2)
                  : BorderSide.none,
            ),
          ),
          child: loading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: <Widget>[
                    if (icon != null) Icon(icon, size: 20, color: foreground),
                    Text(
                      text,
                      style: context.p.copyWith(color: foreground),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
