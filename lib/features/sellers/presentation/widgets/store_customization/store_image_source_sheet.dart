import 'dart:io';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/files/helpers/review_media_helper.dart';

Future<File?> showStoreImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<File?>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () async {
                final file = await ReviewMediaHelper.pickFromGallery();

                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext, file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                final file = await ReviewMediaHelper.takePhoto();

                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext, file);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
