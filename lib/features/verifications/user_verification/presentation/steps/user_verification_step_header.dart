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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: colors.primary, size: 34),
        ),
        const SizedBox(height: 28),
        Text(title, style: context.h3.copyWith(fontSize: 32)),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: context.pMuted.copyWith(fontSize: 16, height: 1.45),
        ),
      ],
    );
  }
}
