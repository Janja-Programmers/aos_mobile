import 'dart:io';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_result.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef UploadMediaFn =
    Future<Either<Failure, MediaUploadResult>> Function(File file);

class MediaHelper {
  MediaHelper._();

  static final ImagePicker _picker = ImagePicker();

  // -------------------------
  // PICKERS
  // -------------------------

  static Future<File?> pickImageWithChoice(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return null;

    final image = await _picker.pickImage(source: source, imageQuality: 80);
    return image == null ? null : File(image.path);
  }

  static Future<File?> pickVideoWithChoice(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.video_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: const Text('Record a video'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return null;

    final video = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 2),
    );

    return video == null ? null : File(video.path);
  }

  static Future<File?> pickVideoFromGallery() async {
    final video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );

    return video == null ? null : File(video.path);
  }

  static Future<File?> recordVideoFromCamera() async {
    final video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 10),
    );

    return video == null ? null : File(video.path);
  }

  static Future<File?> pickImageFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return image == null ? null : File(image.path);
  }

  static Future<File?> pickImageFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    return image == null ? null : File(image.path);
  }

  static Future<File?> pickImage({bool fromCamera = false}) {
    return fromCamera ? pickImageFromCamera() : pickImageFromGallery();
  }

  // -------------------------
  // UPLOAD
  // -------------------------

  static Future<MediaUploadResult?> uploadSingle({
    required Object ref,
    required File file,
    required UploadMediaFn uploadFn,
  }) async {
    final res = await uploadFn(file);
    return res.fold((_) => null, (data) => data);
  }

  static Future<List<MediaUploadResult>> uploadMultiple({
    required Object ref,
    required List<File> files,
    required UploadMediaFn uploadFn,
  }) async {
    final futures = files.map((file) => uploadFn(file)).toList();
    final responses = await Future.wait(futures);
    final results = <MediaUploadResult>[];

    for (final res in responses) {
      res.fold((_) {}, results.add);
    }

    return results;
  }

  // -------------------------
  // PICK DOCUMENT / ANY FILE
  // -------------------------

  static const int maxFileSizeMB = 25;

  static Future<File?> pickAnyFile() async {
    final result = await FilePicker.pickFiles();

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    final file = File(path);

    final isValid = _validateFileSize(file);
    if (!isValid) return null;

    return file;
  }

  static Future<File?> pickDocument() {
    return pickAnyFile();
  }

  static Future<List<File>> pickImagesFromGallery({
    int imageQuality = 80,
  }) async {
    final files = await _picker.pickMultiImage(imageQuality: imageQuality);

    if (files.isEmpty) return [];

    return files.map((xFile) => File(xFile.path)).toList();
  }

  static Future<File?> pickMediaFromGallery() async {
    final result = await FilePicker.pickFiles(type: FileType.media);

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    final file = File(path);

    final isValid = _validateFileSize(file);
    if (!isValid) return null;

    return file;
  }

  // -------------------------
  // VALIDATION
  // -------------------------

  static bool _validateFileSize(File file) {
    if (!file.existsSync()) return false;

    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);

    return sizeInBytes > 0 && sizeInMB <= maxFileSizeMB;
  }
}
