import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortCard extends StatelessWidget {
  final Short short;
  final VoidCallback onTap;

  const ShortCard({super.key, required this.short, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final caption = short.caption.toString();
    final imageUrl = short.thumbnailUrl ?? '';
    final avatarUrl = buildFileUrl(short.sellerAvator);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: colors.border,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: colors.border,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: colors.error,
                  child: const Icon(Icons.broken_image),
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
                      name: short.sellerShopName ?? 'Shop',
                    ),
                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        short.sellerShopName ?? 'Shop',
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
      ),
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
      backgroundColor: colors.colorScheme.primary.withOpacity(.2),
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
