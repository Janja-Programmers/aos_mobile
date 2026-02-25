import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/widgets/subcategories_grid.dart';

class SubcategoryPanel extends StatelessWidget {
  const SubcategoryPanel({
    super.key,
    required this.parent,
    required this.children,
    required this.buildIconUrl,
    this.onTap,
  });

  final CategoryNode parent;
  final List<CategoryNode> children;
  final String? Function(String?) buildIconUrl;
  final ValueChanged<CategoryNode>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Title
          Text(
            parent.name.isEmpty ? 'Categories' : parent.name,
            style: context.subtitle,
          ),

          const SizedBox(height: 12),

          /// Empty state
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No subcategories yet.',
                style: context.body.copyWith(color: colors.textMuted),
              ),
            )
          else
            SubcategoriesGrid(
              items: children,
              buildIconUrl: buildIconUrl,
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}
