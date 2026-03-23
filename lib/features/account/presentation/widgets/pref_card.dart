import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class PrefCard extends StatelessWidget {
  const PrefCard({
    super.key,
    required this.leading,
    required this.title,
    required this.value,
    required this.description,
    required this.onTap,
  });

  final IconData leading;
  final String title;
  final String value;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              /// Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(leading, color: colors.primary, size: 26),
              ),

              const SizedBox(width: 12),

              /// Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title + Value row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: context.h6.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(value, style: context.p),

                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: colors.textMuted,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// Description row
                    Text(description, style: context.pMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
