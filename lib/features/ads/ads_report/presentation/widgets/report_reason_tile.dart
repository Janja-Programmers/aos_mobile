import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_report/presentation/widgets/report_radio_circle.dart';
import 'package:flutter/material.dart';

class ReportReasonTile extends StatelessWidget {
  const ReportReasonTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.mutedColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: mutedColor),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: context.p)),
            ReportRadioCircle(selected: selected, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
