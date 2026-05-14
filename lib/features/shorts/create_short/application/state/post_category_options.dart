import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';

class PostCategoryOption {
  final String id;
  final String label;
  final IconData icon;
  final String contentMode;
  final String description;
  final bool requiresAd;

  const PostCategoryOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.contentMode,
    required this.description,
    this.requiresAd = false,
  });
}

const List<PostCategoryOption> postCategoriesData = [
  PostCategoryOption(
    id: 'business',
    label: 'Business',
    icon: Icons.store_outlined,
    requiresAd: true,
    contentMode: ShortContentModes.shop,
    description:
        'Share business updates, promotions, services, and insights. Connect with customers and grow your brand through engaging content.',
  ),
  PostCategoryOption(
    id: 'geo',
    label: 'Geo',
    icon: Icons.landscape_outlined,
    contentMode: ShortContentModes.geo,
    description:
        'Explore and share stunnning landscapes, mountains, nature trails, waterfalls, and geographical wonders from anywhere in the world.',
  ),
  PostCategoryOption(
    id: 'talents',
    label: 'Talent',
    icon: Icons.star_border_rounded,
    contentMode: ShortContentModes.talents,
    description:
        'Showcase your skills - music, art, fashion, sports and more. Let your creativity reach an audience that appreciates it.',
  ),
  PostCategoryOption(
    id: 'learn',
    label: 'Learn',
    icon: Icons.health_and_safety_outlined,
    contentMode: ShortContentModes.learn,
    description:
        'Share health tips. wellness insights, tech reviews, and innovations that are shaping everyday life around the world.',
  ),
];
