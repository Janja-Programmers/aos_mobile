import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum ImageHeaderMediaKind { image, video }

class ImageHeaderOverlayActions extends StatelessWidget {
  const ImageHeaderOverlayActions({
    super.key,
    required this.isFavorite,
    this.isFavoritePending = false,
    this.onShareTap,
    this.onFavoriteTap,
  });

  final bool isFavorite;
  final bool isFavoritePending;
  final VoidCallback? onShareTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleActionButton(
          icon: Icons.share_outlined,
          tooltip: 'Share ad',
          onTap: onShareTap,
        ),
        const SizedBox(width: 2.5),
        _CircleActionButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          tooltip: isFavorite ? 'Remove from wishlist' : 'Add to wishlist',
          isLoading: isFavoritePending,
          onTap: isFavoritePending ? null : onFavoriteTap,
        ),
      ],
    );
  }
}

class ImageHeaderPageIndicators extends StatelessWidget {
  const ImageHeaderPageIndicators({
    super.key,
    required this.count,
    required this.selected,
  });

  final int count;
  final int selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final active = index == selected;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 6,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: active
                    ? colors.primary
                    : colors.white.withValues(alpha: 0.88),
                boxShadow: [
                  BoxShadow(
                    color: colors.black.withValues(alpha: .8),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ImageHeaderThumbnailStrip extends StatelessWidget {
  const ImageHeaderThumbnailStrip({
    super.key,
    required this.media,
    required this.selected,
    required this.posterImage,
    required this.onSelect,
  });

  final List<ImageHeaderMediaItem> media;
  final int selected;
  final String? posterImage;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = media[index];
          final active = index == selected;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: item.isVideo ? 56 : 44,
              height: 48,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: active ? primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: item.isVideo
                    ? _VideoThumbnail(posterImage: posterImage)
                    : _NetworkThumbnail(url: item.url),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageHeaderMainMedia extends StatelessWidget {
  const ImageHeaderMainMedia({
    super.key,
    required this.item,
    required this.posterImage,
    required this.videoController,
    required this.init,
    required this.chewieController,
    this.onImageTap,
  });

  final ImageHeaderMediaItem item;
  final String? posterImage;
  final VideoPlayerController? videoController;
  final Future<void>? init;
  final ChewieController? chewieController;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    if (!item.isVideo) {
      return GestureDetector(
        onTap: onImageTap,
        child: Image.network(
          buildFileUrl(item.url) ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return const Center(child: Icon(Icons.broken_image_outlined));
          },
        ),
      );
    }

    if (init == null || videoController == null) {
      return VideoPoster(posterImage: posterImage);
    }

    return FutureBuilder<void>(
      future: init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !videoController!.value.isInitialized ||
            chewieController == null) {
          return VideoPoster(posterImage: posterImage);
        }

        return Chewie(controller: chewieController!);
      },
    );
  }
}

class VideoPoster extends StatelessWidget {
  const VideoPoster({super.key, required this.posterImage});

  final String? posterImage;

  @override
  Widget build(BuildContext context) {
    final poster = (posterImage ?? '').trim();

    if (poster.isEmpty) {
      return const Center(child: Icon(Icons.videocam_outlined, size: 44));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          buildFileUrl(poster) ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return const Center(child: Icon(Icons.broken_image_outlined));
          },
        ),
        const Center(child: _PlayBadge(size: 56)),
      ],
    );
  }
}

class ImageHeaderMediaItem {
  const ImageHeaderMediaItem._(this.kind, this.url);

  final ImageHeaderMediaKind kind;
  final String url;

  factory ImageHeaderMediaItem.image(String url) {
    return ImageHeaderMediaItem._(ImageHeaderMediaKind.image, url);
  }

  factory ImageHeaderMediaItem.video(String url) {
    return ImageHeaderMediaItem._(ImageHeaderMediaKind.video, url);
  }

  bool get isVideo => kind == ImageHeaderMediaKind.video;
}

class _NetworkThumbnail extends StatelessWidget {
  const _NetworkThumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      buildFileUrl(url) ?? '',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return const Center(child: Icon(Icons.broken_image_outlined, size: 18));
      },
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.posterImage});

  final String? posterImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final poster = (posterImage ?? '').trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (poster.isNotEmpty)
          Image.network(
            buildFileUrl(poster) ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return ColoredBox(color: colors.black);
            },
          )
        else
          ColoredBox(color: colors.black),

        ColoredBox(color: colors.black.withValues(alpha: 0.45)),

        const Center(child: _PlayBadge(size: 24)),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.tooltip,
    this.isLoading = false,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    )
                  : Icon(icon, size: 20, color: colors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: colors.black, shape: BoxShape.circle),
      child: Icon(
        Icons.play_arrow_rounded,
        color: colors.white,
        size: size * 0.58,
      ),
    );
  }
}
