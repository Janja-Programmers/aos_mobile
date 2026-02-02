import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/catalog/providers/categories_controller.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/utils/category_icon_url.dart';
import 'package:africaonlinestores/features/ads/utils/file_url.dart';

class SelectCategoryScreen extends ConsumerWidget {
  const SelectCategoryScreen({super.key, this.parent});

  final CategoryNode? parent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriesControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final nodes = parent != null ? parent!.children : state.parents;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          parent?.name ?? 'Select Category',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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

                return Material(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      if (hasChildren) {
                        // ✅ Await child picker
                        final result = await context.push<Map<String, dynamic>>(
                          AppRoutes.selectCategory,
                          extra: n,
                        );

                        // ✅ Forward result upward if user selected a leaf
                        if (result != null && context.mounted) {
                          Navigator.of(context).pop(result);
                        }
                      } else {
                        Navigator.of(
                          context,
                        ).pop({'id': n.id, 'label': n.name});
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: iconUrl == null
                                ? Icon(
                                    Icons.category_outlined,
                                    color: scheme.primary,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      buildFileUrl(iconUrl) ?? iconUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.category_outlined,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (hasChildren) const SizedBox(height: 2),
                                if (hasChildren)
                                  Text(
                                    '${n.children.length} subcategories',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context).hintColor,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
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
