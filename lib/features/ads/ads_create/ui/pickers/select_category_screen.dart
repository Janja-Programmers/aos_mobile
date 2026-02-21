import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/utils/category_icon_url.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';

class SelectCategoryScreen extends ConsumerWidget {
  const SelectCategoryScreen({super.key, this.parent});

  final CategoryNode? parent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriesControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final nodes = parent != null ? parent!.children : state.parents;

    return Scaffold(
      backgroundColor: context.appColors.border,
      appBar: AppBar(
        backgroundColor: context.appColors.surface,
        title: Text(parent?.name ?? 'Select Category', style: context.h5),
      ),

      body: state.loading && state.parents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: nodes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),

              itemBuilder: (context, i) {
                final n = nodes[i];
                final hasChildren = n.children.isNotEmpty;
                final iconUrl = buildCategoryIconUrl(n.icon);

                final colors = context.appColors;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      if (hasChildren) {
                        final result = await context.push<Map<String, dynamic>>(
                          AppRoutes.selectCategory,
                          extra: n,
                        );

                        if (result != null && context.mounted) {
                          Navigator.of(context).pop(result);
                        }
                      } else {
                        Navigator.of(
                          context,
                        ).pop({'id': n.id, 'label': n.name});
                      }
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),

                      child: Row(
                        children: [
                          // Icon container
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: scheme.onSurfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: iconUrl == null
                                ? Icon(
                                    Icons.category_outlined,
                                    color: colors.primary,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      buildFileUrl(iconUrl) ?? iconUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.category_outlined,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 12),

                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.name, style: context.pStrong),

                                if (hasChildren) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${n.children.length} subcategories',
                                    style: context.pMuted,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Chevron
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
