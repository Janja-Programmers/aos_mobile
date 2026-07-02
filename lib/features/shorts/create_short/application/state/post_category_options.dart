import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';
import 'package:flutter/material.dart';

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
    id: 'shop',
    label: 'Shop',
    icon: Icons.store_outlined,
    requiresAd: true,
    contentMode: ShortContentModes.shop,
    description:
        'Share business updates, promotions, services, and insights. Connect with customers and grow your brand through engaging content.',
  ),
  PostCategoryOption(
    id: 'geo',
    label: 'Geo',
    icon: Icons.public,
    contentMode: ShortContentModes.geo,
    description:
        'Explore and share stunnning landscapes, mountains, nature trails, waterfalls, and geographical wonders from anywhere in the world.',
  ),
  PostCategoryOption(
    id: 'vibes',
    label: 'Vibes',
    icon: Icons.emoji_events_outlined,
    contentMode: ShortContentModes.vibes,
    description:
        'Showcase your skills - music, art, fashion, sports and more. Let your creativity reach an audience that appreciates it.',
  ),
  PostCategoryOption(
    id: 'learn',
    label: 'Learn',
    icon: Icons.school_outlined,
    contentMode: ShortContentModes.learn,
    description:
        'Share health tips. wellness insights, tech reviews, and innovations that are shaping everyday life around the world.',
  ),
];
