import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

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

    if (thumbPath != null) {
      setState(() {
        _thumbnail = File(thumbPath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _thumbnail == null
                ? Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : Image.file(
                    _thumbnail!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
          ),

          // Play icon overlay
          const Positioned.fill(
            child: Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 50,
                color: Colors.white70,
              ),
            ),
          ),

          // 3 dots menu
          Positioned(
            top: 6,
            right: 6,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 120),
              onSelected: (v) {
                if (v == 'delete') widget.onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'delete',
                  height: 36,
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
