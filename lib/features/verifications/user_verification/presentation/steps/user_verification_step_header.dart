import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class UserVerificationStepHeader extends StatelessWidget {
  const UserVerificationStepHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final tileExtent = compact ? 56.0 : 64.0;
        final tileRadius = compact ? 16.0 : 18.0;
        final iconSize = compact ? 26.0 : 28.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: tileExtent,
              height: tileExtent,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(tileRadius),
              ),
              child: Icon(icon, color: colors.primary, size: iconSize),
            ),
            SizedBox(height: compact ? 16 : 18),
            Text(
              title,
              style: context.h4.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: context.pMuted.copyWith(height: 1.4)),
          ],
        );
      },
    );
  }
}
