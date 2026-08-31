import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    this.onLike,
    this.onDislike,
  });

  final AdReview review;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatarLetter = review.reviewer.isNotEmpty
        ? review.reviewer[0].toUpperCase()
        : '?';
    final formattedDate = review.creation != null
        ? '${_month(review.creation!.month)} ${review.creation!.day}, ${review.creation!.year}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.primaryRedSoft,
              foregroundImage: buildFileUrl(review.reviewerAvatar) == null
                  ? null
                  : AppImageDecode.networkProvider(
                      context,
                      buildFileUrl(review.reviewerAvatar)!,
                      logicalWidth: 36,
                      logicalHeight: 36,
                    ),
              child: Text(
                avatarLetter,
                style: context.pStrong.copyWith(color: colors.surface),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.reviewer, style: context.pStrong),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StarRating(rating: review.rating),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          formattedDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.p.copyWith(color: colors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (review.title.trim().isNotEmpty) ...[
          Text(review.title, style: context.pStrong),
          const SizedBox(height: 8),
        ],
        Text(review.comment, style: context.p),
        if (review.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ReviewImages(images: review.images),
        ],
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Helpful?',
              style: context.p.copyWith(color: colors.textMuted),
            ),
            const SizedBox(width: 4),
            _ReactionButton(
              semanticLabel: review.isLiked
                  ? 'Remove helpful reaction'
                  : 'Mark review as helpful',
              selected: review.isLiked,
              selectedIcon: Icons.thumb_up,
              unselectedIcon: Icons.thumb_up_alt_outlined,
              count: review.likeCount,
              onTap: onLike,
            ),
            const SizedBox(width: 2),
            _ReactionButton(
              semanticLabel: review.isDisliked
                  ? 'Remove not helpful reaction'
                  : 'Mark review as not helpful',
              selected: review.isDisliked,
              selectedIcon: Icons.thumb_down,
              unselectedIcon: Icons.thumb_down_alt_outlined,
              count: review.dislikeCount,
              onTap: onDislike,
            ),
          ],
        ),
      ],
    );
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

class _ReviewImages extends StatelessWidget {
  const _ReviewImages({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final resolvedImages = images
        .map(buildFileUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList(growable: false);

    if (resolvedImages.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: resolvedImages.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return AppNetworkImage(
            url: resolvedImages[index],
            width: 96,
            height: 96,
            borderRadius: BorderRadius.circular(10),
          );
        },
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.semanticLabel,
    required this.selected,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.count,
    required this.onTap,
  });

  final String semanticLabel;
  final bool selected;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = selected ? colors.primary : colors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? selectedIcon : unselectedIcon,
                    size: 18,
                    color: foreground,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($count)',
                    style: context.p.copyWith(color: foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final normalizedRating = rating.clamp(0, 5).toDouble();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starPosition = index + 1;
        final IconData icon;
        final Color color;

        if (normalizedRating >= starPosition) {
          icon = Icons.star;
          color = colors.amber;
        } else if (normalizedRating >= starPosition - 0.5) {
          icon = Icons.star_half;
          color = colors.amber;
        } else {
          icon = Icons.star_border;
          color = colors.border;
        }

        return Icon(icon, size: 14, color: color);
      }),
    );
  }
}
