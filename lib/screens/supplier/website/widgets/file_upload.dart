import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '/core/utils/permissions.dart';

import 'labeled_card.dart';

class ImagePickerField extends StatelessWidget {
  final List<String> paths;
  final ValueChanged<List<String>> onChanged;

  const ImagePickerField({
    super.key,
    required this.paths,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (res == null || res.files.isEmpty) return;
    onChanged(res.files.map((f) => f.path!).toList());
  }

  @override
  Widget build(BuildContext context) => LabeledCard(
    label: 'Images',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        paths.isEmpty
            ? const Text('No images selected')
            : Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  paths.map((p) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(p),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
            ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.photo_library),
          label: const Text('Pick Images'),
        ),
      ],
    ),
  );
}

// ───── video picker field ─────
class VideoPickerField extends StatelessWidget {
  final String? path;
  final ValueChanged<String?> onChanged;

  const VideoPickerField({
    super.key,
    required this.path,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    if (!await checkStoragePermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission required')),
      );
      return;
    }
    final res = await FilePicker.platform.pickFiles(type: FileType.video);
    if (res != null && res.files.single.path != null) {
      onChanged(res.files.single.path);
    }
  }

  @override
  Widget build(BuildContext context) => LabeledCard(
    label: 'Demo Video',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        path == null
            ? const Text('No video selected')
            : Chip(label: Text(path!.split('/').last)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.videocam),
          label: const Text('Pick Video'),
        ),
      ],
    ),
  );
}
