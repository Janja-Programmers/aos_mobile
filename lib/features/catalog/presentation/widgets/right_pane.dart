import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/routing/navigation.dart';

import 'package:africaonlinestores/shared/components/app_carousel.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/presentation/widgets/for_you_section.dart';
import 'package:africaonlinestores/features/catalog/presentation/widgets/subcategories_panel.dart';

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
    final children = parent.children;

    /// Build banner images (3 max)
    final bannerUrls = <String?>[buildIconUrl(parent.icon), null, null];

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const SizedBox(height: 12),

        /// 🔥 Top Banner Carousel
        AppCarousel(
          variant: AppCarouselVariant.secondary,
          height: _bannerHeight(context),
          items: bannerUrls
              .where((e) => e != null)
              .map((url) => AppCarouselItem(imageUrl: url))
              .toList(),
        ),

        const SizedBox(height: 12),

        /// 🔥 Subcategories Section
        SubcategoryPanel(
          parent: parent,
          children: children,
          buildIconUrl: buildIconUrl,
          onTap: (cat) => openAllAds(context, categoryId: cat.id),
        ),

        const SizedBox(height: 16),

        /// 🔥 For You Section
        ForYouSection(categoryId: parent.id),
      ],
    );
  }

  double _bannerHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.33).clamp(110.0, 160.0);
  }
}
