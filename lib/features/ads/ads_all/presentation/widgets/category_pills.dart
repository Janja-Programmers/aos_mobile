import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

class CategoryPills extends StatelessWidget {
  const CategoryPills({
    super.key,
    required this.children,
    required this.selectedId,
    required this.onSelect,
    this.parentLabel,
  });

  final List<CategoryNode> children;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final String? parentLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: children.length + 1,
        itemBuilder: (context, i) {
          final isAll = i == 0;

          final id = isAll ? null : children[i - 1].id;

          final label = isAll
              ? (parentLabel != null
                    ? 'All ${parentLabel!.split(' ').first}'
                    : 'All')
              : children[i - 1].name;

          final selected = (isAll && selectedId == null) || id == selectedId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              selected: selected,
              onSelected: (_) => onSelect(id),
              backgroundColor: colors.surface,
              selectedColor: colors.primary.withOpacity(.15),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide.none,
              ),
              label: Text(
                label,
                style: context.p.copyWith(
                  color: selected
                      ? colors.primary.withOpacity(.85)
                      : colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
