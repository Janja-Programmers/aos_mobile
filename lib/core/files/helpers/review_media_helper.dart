import 'dart:io';

import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/domain/upload_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ReviewMediaHelper {
  ReviewMediaHelper._();

  static final ImagePicker _picker = ImagePicker();
  static const int maxImages = 5;

  static Future<File?> takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    return image == null ? null : File(image.path);
  }

  static Future<List<File>> pickFromGallery() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    return images.map((image) => File(image.path)).toList();
  }

  static Future<List<String>> upload({
    required WidgetRef ref,
    required List<File> files,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final result = await ref.read(filesApiProvider).uploadMedia(file: file);

      result.fold((_) {}, (UploadedFile data) {
        if (data.url.isNotEmpty) {
          urls.add(data.url);
        }
      });
    }

    return urls;
  }
}
