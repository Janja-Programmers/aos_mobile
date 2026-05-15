import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/my_post_tile.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/sellers/domain/storefront_post.dart';

class MyPostsSection extends StatelessWidget {
  const MyPostsSection({
    super.key,
    required this.loading,
    required this.error,
    required this.posts,
    required this.onRefresh,
    required this.onPostMenuTap,
  });

  final bool loading;
  final String? error;
  final List<StorefrontPost> posts;
  final VoidCallback onRefresh;
  final void Function(StorefrontPost post) onPostMenuTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (loading && posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null && posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: onRefresh, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 44,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 10),
            Text(
              'No posts yet',
              style: context.p.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Your shorts will appear here after publishing.',
              style: context.small.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'My Posts (${posts.length})',
              style: context.p.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => ShortsNavigation.toPostShort(context),
              icon: Icon(Icons.add, size: 18, color: colors.primary),
              label: Text(
                'New Post',
                style: context.small.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...posts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MyPostTile(post: post, onMenuTap: () => onPostMenuTap(post)),
          ),
        ),
      ],
    );
  }
}
