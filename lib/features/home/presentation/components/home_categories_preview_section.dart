import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';

/// Categories preview section (horizontal carousel) with a "See all" link.
/// Responsive and overflow-safe.
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
          /// Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Categories',
                  style: context.h5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(AppRoutes.nCategories),
                child: Text(
                  'See all',
                  style: context.p.copyWith(color: colors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// Loading
          if (state.loading && items.isEmpty)
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) => const Column(
                  children: [
                    ShimmerBox(width: 58, height: 58, shape: BoxShape.circle),
                    SizedBox(height: 8),
                    ShimmerBox(width: 60, height: 12),
                  ],
                ),
              ),
            )
          /// Categories list
          else if (items.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = items[i];
                  return _CategoryTile(
                    item: c,
                    onTap: () => context.pushNamed(
                      AppRoutes.nAllAds,
                      pathParameters: {'categoryId': c.id},
                    ),
                  );
                },
              ),
            )
          /// Error
          else if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.errorMessage!,
                style: context.p.copyWith(color: colors.error),
              ),
            ),
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

    final hasIcon = item.icon != null && item.icon!.trim().isNotEmpty;

    final url = hasIcon ? buildFileUrl(item.icon!) : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Circle container
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: ClipOval(
                child: url != null
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: 58,
                        height: 58,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.category_outlined,
                          color: colors.textMuted,
                        ),
                      )
                    : Icon(Icons.category_outlined, color: colors.textMuted),
              ),
            ),

            const SizedBox(height: 8),

            /// Name
            Flexible(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.p.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
