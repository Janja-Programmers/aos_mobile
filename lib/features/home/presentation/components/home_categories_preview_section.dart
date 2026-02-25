import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';

import 'package:africaonlinestores/shared/shimmer/category_shimmer.dart';

class HomeCategoriesPreviewSection extends ConsumerWidget {
  const HomeCategoriesPreviewSection({super.key, this.limit = 10});

  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(categoriesControllerProvider);

    final items = state.parents.take(limit).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Categories',
                    style: context.title, // 18 w600 from DS
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => context.pushNamed(AppRoutes.nCategories),
                  child: Text(
                    'See all',
                    style: context.p.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// LOADING
            if (state.loading && items.isEmpty)
              SizedBox(
                height: 95,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  separatorBuilder: (_, _) => const SizedBox(width: 20),
                  itemBuilder: (_, _) => const CategoryShimmer(),
                ),
              )
            /// CONTENT
            else if (items.isNotEmpty)
              SizedBox(
                height: 95,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 20),
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
            /// ERROR
            else if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errorMessage!,
                  style: context.body.copyWith(color: colors.error),
                ),
              ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 72, // SPEC
        child: Column(
          children: [
            /// ICON CIRCLE
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colors.elevated,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: url != null
                  ? ClipOval(
                      child: Image.network(
                        url,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.category_outlined,
                          size: 26,
                          color: colors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.category_outlined,
                      size: 26,
                      color: colors.primary,
                    ),
            ),

            const SizedBox(height: 8),

            /// LABEL
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStylesX(context).caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
