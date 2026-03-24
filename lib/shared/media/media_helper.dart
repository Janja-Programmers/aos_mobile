import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

typedef UploadFn =
    Future<Either<Failure, Map<String, dynamic>>> Function(File file);

class MediaHelper {
  MediaHelper._();

  static final _picker = ImagePicker();

  // -------------------------
  // PICKERS
  // -------------------------j

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
  static Future<String?> uploadSingle({
    required WidgetRef ref,
    required File file,
    required UploadFn uploadFn,
  }) async {
    final res = await uploadFn(file);

    return res.fold((_) => null, (data) => _extractUrl(data));
  }

  /// Upload MULTIPLE files
  static Future<List<String>> uploadMultiple({
    required WidgetRef ref,
    required List<File> files,
    required UploadFn uploadFn,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final res = await uploadFn(file);

      res.fold((_) {}, (data) {
        final url = _extractUrl(data);
        if (url != null) urls.add(url);
      });
    }

    return urls;
  }

  // -------------------------
  // ALLOWED DOCUMENT TYPES
  // -------------------------

  static const allowedDocExtensions = ['pdf', 'doc', 'docx'];

  static const maxFileSizeMB = 5;

  // -------------------------
  // PICK DOCUMENT
  // -------------------------

  static Future<File?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedDocExtensions,
    );

    if (result == null) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    final file = File(path);

    // Extra validation
    final isValid = await _validateFile(file);
    if (!isValid) return null;

    return file;
  }

  // -------------------------
  // VALIDATION
  // -------------------------

  static Future<bool> _validateFile(File file) async {
    final sizeInBytes = await file.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);

    if (sizeInMB > maxFileSizeMB) {
      return false;
    }

    final ext = file.path.split('.').last.toLowerCase();

    if (!allowedDocExtensions.contains(ext)) {
      return false;
    }

    return true;
  }

  // -------------------------
  // INTERNAL
  // -------------------------

  static String? _extractUrl(Map<String, dynamic> data) {
    final url = data['url'];
    if (url == null) return null;

    final val = url.toString().trim();
    return val.isEmpty ? null : val;
  }
}
