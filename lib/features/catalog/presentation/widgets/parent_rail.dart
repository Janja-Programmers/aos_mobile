import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

class ParentsRail extends StatelessWidget {
  const ParentsRail({
    super.key,
    required this.width,
    required this.parents,
    required this.selectedId,
    required this.onSelect,
    required this.buildIconUrl,
  });

  final double width;
  final List<CategoryNode> parents;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final String? Function(String?) buildIconUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: parents.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final parent = parents[index];
          final selected = parent.id == selectedId;
          final iconUrl = buildIconUrl(parent.icon);

          return InkWell(
            onTap: () => onSelect(parent.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withOpacity(0.08)
                    : context.appColors.surface,
                border: Border(
                  left: BorderSide(
                    width: 3,
                    color: selected
                        ? scheme.primary
                        : context.appColors.surface,
                  ),
                ),
              ),
              child: Column(
                children: [
                  /// Icon circle
                  Container(
                    width: (width * 0.5).clamp(42.0, 50.0),
                    height: (width * 0.5).clamp(42.0, 50.0),
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: iconUrl == null
                        ? Icon(Icons.category_outlined, color: colors.textMuted)
                        : ClipOval(
                            child: Image.network(
                              iconUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),

                  const SizedBox(height: 6),

                  /// Name
                  Text(
                    parent.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStylesX(context).caption.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? scheme.onSurface : colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
