import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/feeds_routes.dart';
import 'package:flutter/material.dart';

class ShortGridCard extends StatelessWidget {
  final ShortModel short;
  final int index;

  const ShortGridCard({super.key, required this.short, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final caption = short.caption;
    final imageUrl = short.thumbnailUrl;
    final avatarUrl = buildFileUrl(short.creator.avatar);

    return GestureDetector(
      onTap: () => FeedsNavigation.toFeeds(context),
      child: Container(
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(colors),
                ),
              ),
            ),

            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 2),
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
              child: Row(
                children: [
                  _SellerAvatar(
                    avatarUrl: avatarUrl,
                    name: short.creator.displayName,
                  ),
                  const SizedBox(width: 5),

                  Expanded(
                    child: Text(
                      short.creator.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),

                  const SizedBox(width: 4),

                  Text(
                    short.metrics.likeCount.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.thumb_up_alt_outlined, size: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(AppColorTokens colors) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colors.border,
      child: const Center(child: Icon(Icons.play_arrow)),
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  const _SellerAvatar({required this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);

    final initials = _getInitials(name);

    return CircleAvatar(
      radius: 12,
      backgroundColor: colors.colorScheme.primary.withValues(alpha: .2),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              initials,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
