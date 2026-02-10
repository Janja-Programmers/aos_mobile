import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/home/components/ad_details/section_card.dart';

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
            for (final s in specs) _SpecRow(spec: s),
          ],
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.spec});

  final Map<String, dynamic> spec;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    String key = (spec['label'] ?? spec['key'] ?? spec['name'] ?? '')
        .toString();
    String val = (spec['value'] ?? spec['val'] ?? '').toString();

    key = key.trim();
    val = val.trim();

    if (key.isEmpty || val.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              key,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
