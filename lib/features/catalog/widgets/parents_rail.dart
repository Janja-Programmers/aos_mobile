import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: colors.stroke)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final c = parents[index];
          final selected = c.id == selectedId;
          final url = buildIconUrl(c.icon);

          return InkWell(
            onTap: () => onSelect(c.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withAlpha(20)
                    : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    width: 3,
                    color: selected ? scheme.primary : Colors.transparent,
                  ),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: (width * 0.27).clamp(22.0, 28.0),
                    backgroundColor: colors.stroke,
                    foregroundImage: url == null ? null : NetworkImage(url),
                    child: url == null
                        ? Icon(Icons.category_outlined, color: colors.muted)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.1,
                      color: selected ? scheme.onSurface : colors.muted,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 4),
        itemCount: parents.length,
      ),
    );
  }
}
