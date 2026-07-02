import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class ReportInfoCard extends StatelessWidget {
  const ReportInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Help us keep AOS safe. Select the reason that best describes the issue with this listing.',
              style: context.body,
            ),
          ),
        ],
      ),
    );
  }
}
