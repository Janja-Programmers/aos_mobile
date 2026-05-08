import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';

class SellerAboutSection extends StatefulWidget {
  const SellerAboutSection({super.key, required this.about});

  final String? about;

  @override
  State<SellerAboutSection> createState() => _SellerAboutSectionState();
}

class _SellerAboutSectionState extends State<SellerAboutSection> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final hasAbout = widget.about != null && widget.about!.trim().isNotEmpty;

    return SectionCard(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hasAbout ? () => setState(() => expanded = !expanded) : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.storefront, size: 19, color: colors.primary),
                    const SizedBox(width: 10),
                    Text('About', style: context.h6),
                  ],
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),

          if (hasAbout && expanded) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.about!,
                style: context.body.copyWith(height: 1.45),
              ),
            ),

            const SizedBox(height: 16),

            const _InfoRow(
              icon: Icons.location_on_outlined,
              title: 'Nairobi, Kenya',
              subtitle: 'Operating Location',
            ),

            const SizedBox(height: 12),

            const _InfoRow(
              icon: Icons.access_time,
              title: 'Mon–Fri: 8AM – 6PM',
              subtitle: 'Business Hours',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.textMuted, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.pStrong),
              const SizedBox(height: 2),
              Text(subtitle, style: context.pMuted),
            ],
          ),
        ),
      ],
    );
  }
}
