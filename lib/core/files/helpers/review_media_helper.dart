import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/domain/upload_file.dart';

class ReviewMediaHelper {
  ReviewMediaHelper._();

  static final _picker = ImagePicker();
  static const int maxImages = 4;

  static Future<File?> takePhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return x == null ? null : File(x.path);
  }

  static Future<File?> pickFromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    return x == null ? null : File(x.path);
  }

  static Future<List<String>> upload({
    required WidgetRef ref,
    required List<File> files,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final res = await ref.read(filesApiProvider).uploadMedia(file: file);

      res.fold((_) {}, (UploadedFile data) {
        if (data.url.isNotEmpty) {
          urls.add(data.url);
        }
      });
    }

    return urls;
  }
}
