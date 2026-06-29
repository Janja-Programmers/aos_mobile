import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/files/domain/upload_file.dart';
import 'package:africaonlinestores/core/utils/either.dart';

typedef UploadFn = Future<Either<Failure, UploadedFile>> Function(File file);

class MediaHelper {
  MediaHelper._();

  static final _picker = ImagePicker();

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

    final x = await _picker.pickImage(source: source, imageQuality: 80);
    return x == null ? null : File(x.path);
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

    final x = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 2), // optional limit
    );

    return x == null ? null : File(x.path);
  }

  static Future<File?> pickVideoFromGallery() async {
    final x = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );

    return x == null ? null : File(x.path);
  }

  static Future<File?> recordVideoFromCamera() async {
    final x = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 10),
    );

    return x == null ? null : File(x.path);
  }

  static Future<File?> pickImageFromCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return x == null ? null : File(x.path);
  }

  static Future<File?> pickImageFromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    return x == null ? null : File(x.path);
  }

  /// Generic picker (can extend later for files/PDF)
  static Future<File?> pickImage({bool fromCamera = false}) {
    return fromCamera ? pickImageFromCamera() : pickImageFromGallery();
  }

  // -------------------------
  // UPLOAD
  // -------------------------

  /// Upload SINGLE file
  static Future<UploadedFile?> uploadSingle({
    required WidgetRef ref,
    required File file,
    required UploadFn uploadFn,
  }) async {
    final res = await uploadFn(file);

    return res.fold((_) => null, (data) => data);
  }

  /// Upload MULTIPLE files
  static Future<List<UploadedFile>> uploadMultiple({
    required WidgetRef ref,
    required List<File> files,
    required UploadFn uploadFn,
  }) async {
    final futures = files.map((file) => uploadFn(file)).toList();

    final responses = await Future.wait(futures);

    final results = <UploadedFile>[];

    for (final res in responses) {
      res.fold((_) {}, (data) {
        results.add(data);
      });
    }

    return results;
  }

  // -------------------------
  // PICK DOCUMENT / ANY FILE
  // -------------------------

  static const maxFileSizeMB = 25;

  static Future<File?> pickAnyFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    final file = File(path);

    final isValid = await _validateFileSize(file);
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

    return files.map((x) => File(x.path)).toList();
  }

  static Future<File?> pickMediaFromGallery() async {
    final result = await FilePicker.pickFiles(
      type: FileType.media,
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    final file = File(path);

    final isValid = await _validateFileSize(file);
    if (!isValid) return null;

    return file;
  }

  // -------------------------
  // VALIDATION
  // -------------------------

  static Future<bool> _validateFileSize(File file) async {
    final sizeInBytes = await file.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);

    return sizeInMB <= maxFileSizeMB;
  }
}
