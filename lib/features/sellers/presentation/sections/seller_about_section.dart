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
            onTap: hasAbout
                ? () {
                    setState(() => expanded = !expanded);
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'About',
                      style: context.h6.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.textMuted,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          if (hasAbout && expanded) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.about!.trim(),
                style: context.body.copyWith(
                  height: 1.45,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
