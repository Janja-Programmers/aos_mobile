import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/providers/categories_controller.dart';

/// Categories preview section (horizontal list) with a "See all" link.
///
/// By default we only *display* [limit] items. The categories controller already
/// caches the full list in memory, so the preview stays fast.
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
              Text('Categories', style: context.h4),
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
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: state.loading && items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final c = items[i];
                      return _CategoryChip(
                        item: c,
                        onTap: () {
                          // For now we just open full Categories screen.
                          // (Later: deep-link into the selected category.)
                          context.push(AppRoutes.categories);
                        },
                      );
                    },
                  ),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.item, required this.onTap});

  final CategoryNode item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: (item.icon != null && item.icon!.trim().isNotEmpty)
                  ? Image.network(
                      item.icon!,
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.category_outlined,
                        color: colors.textMuted,
                      ),
                    )
                  : Icon(Icons.category_outlined, color: colors.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.p.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
