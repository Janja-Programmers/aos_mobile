import 'dart:io';

import 'package:africaonlinestores/core/media/helpers/review_media_helper.dart';
import 'package:flutter/material.dart';

class ReviewImageSelection {
  const ReviewImageSelection({
    required this.files,
    required this.selectedCount,
    required this.availableSlots,
  });

  final List<File> files;
  final int selectedCount;
  final int availableSlots;

  bool get exceededAvailableSlots => selectedCount > availableSlots;
}

enum _ReviewImageSource { camera, gallery }

Future<ReviewImageSelection?> showImageSourcePicker(
  BuildContext context, {
  required int availableSlots,
}) async {
  if (availableSlots <= 0) return null;

  final source = await showModalBottomSheet<_ReviewImageSource>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(sheetContext, _ReviewImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              subtitle: Text(
                'Select up to $availableSlots ${availableSlots == 1 ? 'photo' : 'photos'}',
              ),
              onTap: () {
                Navigator.pop(sheetContext, _ReviewImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );

  if (source == null) return null;

  if (source == _ReviewImageSource.camera) {
    final file = await ReviewMediaHelper.takePhoto();
    if (file == null) return null;

    return ReviewImageSelection(
      files: [file],
      selectedCount: 1,
      availableSlots: availableSlots,
    );
  }

  final selectedFiles = await ReviewMediaHelper.pickFromGallery();
  if (selectedFiles.isEmpty) return null;

  return ReviewImageSelection(
    files: selectedFiles,
    selectedCount: selectedFiles.length,
    availableSlots: availableSlots,
  );
}
