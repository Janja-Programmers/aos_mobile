import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/bottom_caption_overlay.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/right_metrics_overlay.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/short_badge.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/short_thumbnail.dart';

class ShortCard extends StatelessWidget {
  final Short short;
  final VoidCallback onTap;

  const ShortCard({super.key, required this.short, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final caption = short.caption.toString().trim();
    final imageUrl = short.thumbnailUrl ?? '';

    final sellerName = short.sellerShopName.trim().isNotEmpty == true
        ? short.sellerShopName.trim()
        : 'Shop';

    final avatarUrl = _safeFileUrl(short.sellerAvatar);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border.withOpacity(.55)),
          ),
          child: Stack(
            children: [
              ShortThumbnail(imageUrl: imageUrl),

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.black.withOpacity(.04),
                          colors.black.withOpacity(.08),
                          colors.black.withOpacity(.68),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                left: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShortBadge(contentMode: short.contentMode),
                    const SizedBox(height: 6),
                    if (_statusLabel(short) != null)
                      _StatusBadge(label: _statusLabel(short)!),
                    if (short.isPrivateAudience) ...[
                      const SizedBox(height: 6),
                      _StatusBadge(label: _audienceLabel(short.audience)),
                    ],
                  ],
                ),
              ),

              Positioned(
                right: 7,
                bottom: 12,
                child: RightMetricsOverlay(
                  avatarUrl: avatarUrl,
                  sellerName: sellerName,
                  likeCount: short.metrics.likeCount,
                  commentCount: short.metrics.commentCount,
                  isLiked: short.isLiked,
                ),
              ),

              Positioned(
                left: 9,
                right: 48,
                bottom: 10,
                child: BottomCaptionOverlay(
                  caption: caption,
                  sellerName: sellerName,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _statusLabel(Short short) {
    if (short.isProcessing) return 'Processing';
    if (short.canRetry) return 'Failed';
    if (short.isHidden) return 'Hidden';
    if (short.isDeleted) return 'Deleted';
    return null;
  }

  String _audienceLabel(String audience) {
    switch (audience) {
      case 'followers':
        return 'Followers';
      case 'friends':
        return 'Friends';
      case 'only_me':
        return 'Only me';
      default:
        return 'Private';
    }
  }

  String? _safeFileUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final url = buildFileUrl(value);

    if (url!.trim().isEmpty) return null;

    return url;
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.black.withOpacity(.58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.white.withOpacity(.26)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
