import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

class SubcategoriesGrid extends StatelessWidget {
  const SubcategoriesGrid({
    super.key,
    required this.items,
    required this.buildIconUrl,
    this.onTap,
  });

  final List<CategoryNode> items;
  final String? Function(String?) buildIconUrl;
  final ValueChanged<CategoryNode>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, c) {
        // Force 3 columns (as requested)
        const cols = 3;

        // Tighter spacing
        const crossSpacing = 8.0;
        const mainSpacing = 8.0;

        // Compute tile height from available width so it "squeezes" nicely.
        // This makes tiles shorter on small screens and avoids big vertical gaps.
        final tileW = (c.maxWidth - (crossSpacing * (cols - 1))) / cols;
        final imageH = (tileW * 0.78).clamp(
          52.0,
          70.0,
        ); // slightly smaller image
        final textH = 34.0; // enough for 2 lines
        final tileH = imageH + 6 + textH; // 6 = gap between image and text

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: crossSpacing,
            mainAxisSpacing: mainSpacing,
            mainAxisExtent: tileH, // ✅ controls row height directly
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final url = buildIconUrl(item.icon);

            return InkWell(
              onTap: () => onTap?.call(item),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  SizedBox(
                    height: imageH,
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: url == null
                          ? Icon(
                              Icons.grid_view_outlined,
                              color: colors.textMuted,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: textH,
                    child: Center(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
