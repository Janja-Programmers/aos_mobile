import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.change,
  });

  final IconData icon;
  final String value;
  final String label;

  /// Optional because we are now using real current totals.
  /// We should only show change when the backend eventually returns period data.
  final String? change;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Stack(
        children: [
          if (change != null && change!.trim().isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  change!,
                  style: TextStyle(
                    color: colors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colors.primary, size: 22),

              const SizedBox(height: 16),

              Text(
                value,
                style: context.h5.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: context.small,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
