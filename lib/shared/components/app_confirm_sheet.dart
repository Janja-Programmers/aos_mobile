import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class AppConfirmSheet extends StatelessWidget {
  const AppConfirmSheet({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.message,
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimary,
    required this.onSecondary,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String message;
  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius _sheetRadius = BorderRadius.vertical(
    top: Radius.circular(26),
  );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final viewPadding = mediaQuery.viewPadding;

    final sheetColor = context.appColors.surface.withAlpha(255);

    return SafeArea(
      top: false,
      child: Material(
        color: sheetColor,
        surfaceTintColor: Colors.transparent,
        borderRadius: _sheetRadius,
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            18 + viewPadding.bottom + viewInsets.bottom,
          ),
          color: context.appColors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon badge
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                ),
                child: Center(
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconBg.withAlpha(46),
                    ),
                    child: Icon(
                      icon,
                      color: context.appColors.border,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(title, style: context.h4, textAlign: TextAlign.center),
              const SizedBox(height: 6),

              Text(message, style: context.p, textAlign: TextAlign.center),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: onPrimary,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.appColors.border),
                          shape: const RoundedRectangleBorder(
                            borderRadius: _pill,
                          ),
                          foregroundColor: context.appColors.textPrimary,
                        ),
                        child: Text(
                          primaryText,
                          style: AppTextStylesX(context).button.copyWith(
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onSecondary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.primary,
                          foregroundColor: context.appColors.border,
                          shape: const RoundedRectangleBorder(
                            borderRadius: _pill,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          secondaryText,
                          style: AppTextStylesX(context).button,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
