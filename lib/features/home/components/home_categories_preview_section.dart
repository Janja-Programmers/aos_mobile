import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/utils/file_url.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/providers/categories_controller.dart';

/// Categories preview section (carousel row) with a "See all" link.
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
                onTap: () => context.pushNamed(AppRoutes.categories),
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
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final c = items[i];
                  return _CategoryTile(
                    item: c,
                    onTap: () =>
                        context.pushNamed(AppRoutes.nAllAds, pathParameters: {'categoryId': c.id}),
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.item, required this.onTap});

  final CategoryNode item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final hasIcon = (item.icon != null && item.icon!.trim().isNotEmpty);

    final url = buildFileUrl(item.icon!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: ClipOval(
                child: hasIcon
                    ? CircleAvatar(
                        radius: 28.0,
                        backgroundColor: colors.border,
                        foregroundImage: url == null ? null : NetworkImage(url),
                        child: url == null
                            ? Icon(
                                Icons.category_outlined,
                                color: colors.textMuted,
                              )
                            : null,
                      )
                    : Icon(Icons.category_outlined, color: colors.textMuted),
              ),
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
      ),
    );
  }
}
