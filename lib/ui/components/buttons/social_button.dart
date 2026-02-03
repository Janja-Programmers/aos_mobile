import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: context.appColors.primary,
          side: BorderSide(color: colors.border),
          shape: const RoundedRectangleBorder(borderRadius: AppTheme.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              )
            else
              icon,
            const SizedBox(width: 10),
            Text(loading ? 'Signing in…' : label, style: context.p),
          ],
        ),
      ),
    );
  }
}
