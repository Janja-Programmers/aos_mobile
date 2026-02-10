import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

import 'package:africaonlinestores/features/catalog/widgets/banners_carousel.dart';
import 'package:africaonlinestores/features/catalog/widgets/subcategories_grid.dart';
import 'package:africaonlinestores/features/catalog/widgets/for_you_section.dart';
import 'package:go_router/go_router.dart';

class RightPane extends StatelessWidget {
  const RightPane({
    super.key,
    required this.parent,
    required this.buildIconUrl,
  });

  final CategoryNode parent;
  final String? Function(String?) buildIconUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    final children = parent.children;

    final bannerUrls = <String?>[buildIconUrl(parent.icon), null, null];

    return ListView(
      padding: const EdgeInsets.only(bottom: 10),
      children: [
        const SizedBox(height: 8),

        // ✅ top carousel (3 images)
        BannersCarousel(imageUrls: bannerUrls, height: _bannerHeight(context)),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parent.name.isEmpty ? 'Categories' : parent.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              if (children.isEmpty)
                Text(
                  'No subcategories yet.',
                  style: TextStyle(color: colors.textMuted),
                )
              else
                SubcategoriesGrid(
                  items: children,
                  buildIconUrl: buildIconUrl,
                  onTap: (cat) {
                    final categoryId = cat.id;
                    context.pushNamed(AppRoutes.nAllAds, pathParameters: {'categoryId': categoryId});
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        ForYouSection(onSeeAll: () {}),
      ],
    );
  }

  double _bannerHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // responsive height to avoid overflow on small devices
    return (w * 0.33).clamp(110.0, 160.0);
  }
}
