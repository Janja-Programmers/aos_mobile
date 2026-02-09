import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/providers/categories_controller.dart';

/// Categories preview section (grid row) with a "See all" link.
///
/// Matches the video: show a compact row of categories (usually 4) and...
class HomeCategoriesPreviewSection extends ConsumerWidget {
  const HomeCategoriesPreviewSection({super.key, this.limit = 10});

  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(categoriesControllerProvider);

    final items = state.parents.take(limit).toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Categories', style: context.h5),
              const Spacer(),
              InkWell(
                onTap: () => context.push(AppRoutes.categories),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Text(
                    'See all',
                    style: context.p.copyWith(color: colors.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.loading && items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Row(
              children: List.generate(items.length.clamp(0, 4), (i) {
                final c = items[i];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == items.length - 1 ? 0 : 10,
                    ),
                    child: _CategoryTile(
                      item: c,
                      onTap: () => context.push(AppRoutes.categories),
                    ),
                  ),
                );
              }),
            ),
          if (state.errorMessage != null && items.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: context.p.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.item, required this.onTap});

  final CategoryNode item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: (item.icon != null && item.icon!.trim().isNotEmpty)
                ? Image.network(
                    item.icon!,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.category_outlined, color: colors.textMuted),
                  )
                : Icon(Icons.category_outlined, color: colors.textMuted),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.p.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
