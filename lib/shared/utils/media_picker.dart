import 'dart:io';
import 'package:flutter/material.dart';
import 'file_picker.dart';

import '/core/constants/const.dart';

enum MediaType { image, video }

class MediaPicker extends StatelessWidget {
  final String label;
  final String? filePath;
  final void Function(String path) onPick;
  final MediaType type;

  const MediaPicker({
    super.key,
    required this.label,
    required this.filePath,
    required this.onPick,
    required this.type,
  });

  Future<void> _handlePick(BuildContext context) async {
    final picked =
        type == MediaType.image ? await pickImageFile() : await pickVideoFile();
    if (picked != null) onPick(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl =
        filePath != null && filePath!.startsWith('/files/')
            ? "${ApiRoutes.baseUrl}$filePath"
            : filePath;

    Widget preview;
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      if (type == MediaType.image) {
        preview = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(resolvedUrl), height: 120, fit: BoxFit.cover),
        );
      } else {
        preview = Text(
          resolvedUrl.split('/').last,
          style: const TextStyle(fontStyle: FontStyle.italic),
        );
      }
    } else {
      preview = const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _handlePick(context),
          icon: Icon(type == MediaType.image ? Icons.image : Icons.videocam),
          label: Text(label),
        ),
        const SizedBox(height: 8),
        preview,
      ],
    );
  }
}
