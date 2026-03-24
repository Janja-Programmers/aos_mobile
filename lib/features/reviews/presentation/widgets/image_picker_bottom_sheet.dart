import 'dart:io';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/shared/media/media_helper.dart';

Future<File?> showImageSourcePicker(BuildContext context) {
  return showModalBottomSheet<File>(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                final file = await MediaHelper.pickImageFromCamera();
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final file = await MediaHelper.pickImageFromGallery();
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
          ],
        ),
      );
    },
  );
}
