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
          /// HEADER
          GestureDetector(
            onTap: hasAbout ? () => setState(() => expanded = !expanded) : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.store, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Text('About', style: context.p),
                  ],
                ),

                if (hasAbout)
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
              ],
            ),
          ),

          if (hasAbout && expanded) ...[
            const SizedBox(height: 12),

            Text(widget.about!, style: context.body),
          ],
        ],
      ),
    );
  }
}
