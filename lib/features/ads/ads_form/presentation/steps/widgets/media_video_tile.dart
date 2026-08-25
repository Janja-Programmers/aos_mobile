import 'dart:io';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaVideoTile extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onDelete;

  const MediaVideoTile({
    super.key,
    required this.videoUrl,
    required this.onDelete,
  });

  @override
  State<MediaVideoTile> createState() => _MediaVideoTileState();
}

class _MediaVideoTileState extends State<MediaVideoTile> {
  File? _thumbnail;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(MediaVideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _thumbnail = null;
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    final url = buildFileUrl(widget.videoUrl);
    if (url == null) return;

    final dir = await getTemporaryDirectory();

    final thumbPath = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: dir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      quality: 75,
    );

    if (thumbPath != null && mounted) {
      setState(() {
        _thumbnail = File(thumbPath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _thumbnail == null
                ? ColoredBox(
                    color: colors.black,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : Image.file(
                    _thumbnail!,
                    fit: BoxFit.cover,
                    width: 110,
                    height: 110,
                    cacheWidth: 440,
                    cacheHeight: 440,
                  ),
          ),

          /// Play icon
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 42,
                color: colors.white,
              ),
            ),
          ),

          /// 3 dots menu
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colors.white, size: 18),
                color: colors.white,
                padding: EdgeInsets.zero,
                splashRadius: 18,
                constraints: const BoxConstraints(minWidth: 140),
                onSelected: (v) {
                  if (v == 'delete') widget.onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    height: 36,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: context.p.copyWith(color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
