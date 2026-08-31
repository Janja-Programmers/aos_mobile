import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

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
      builder: (context, constraints) {
        const columns = 3;
        const crossSpacing = 12.0;
        const mainSpacing = 12.0;

        const totalSpacing = crossSpacing * (columns - 1);
        final tileWidth = (constraints.maxWidth - totalSpacing) / columns;

        // Slightly more premium proportions
        final imageHeight = (tileWidth * 0.80).clamp(56.0, 80.0);
        const textHeight = 36.0;
        final tileHeight = imageHeight + 8 + textHeight;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossSpacing,
            mainAxisSpacing: mainSpacing,
            mainAxisExtent: tileHeight,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final iconUrl = buildIconUrl(item.icon);

            return InkWell(
              onTap: onTap == null ? null : () => onTap!(item),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  /// Image container
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.elevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      alignment: Alignment.center,
                      child: iconUrl == null
                          ? Icon(
                              Icons.grid_view_outlined,
                              size: 26,
                              color: colors.textMuted,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AppNetworkImage(
                                url: iconUrl,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.grid_view_outlined,
                                  size: 26,
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Title
                  SizedBox(
                    height: textHeight,
                    child: Center(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStylesX(context).caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
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
