import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/section_card.dart';

class AdProductDetailsSection extends StatelessWidget {
  const AdProductDetailsSection({
    super.key,
    required this.description,
    required this.specs,
  });

  final String description;
  final List<Map<String, dynamic>> specs;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Product Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            description.trim().isEmpty ? 'No description.' : description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 14),
          if (specs.isNotEmpty) ...[
            const Text(
              'Specifications',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < specs.length; i++)
              _SpecRow(spec: specs[i], showDivider: i != specs.length - 1),
          ],
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.spec, required this.showDivider});

  final Map<String, dynamic> spec;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final String key = (spec['label'] ?? spec['key'] ?? spec['name'] ?? '')
        .toString()
        .trim();

    final String val = (spec['value'] ?? spec['val'] ?? '').toString().trim();

    if (key.isEmpty || val.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 Left vertical indicator
              Container(
                width: 4,
                height: 18,
                margin: const EdgeInsets.only(right: 10, top: 2),
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              /// Key + Value
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: Text(key, style: context.p)),
                    Expanded(
                      child: Text(
                        val,
                        textAlign: TextAlign.left,
                        style: context.pStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// 🔥 Divider
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: context.appColors.textPrimary,
          ),
      ],
    );
  }
}
