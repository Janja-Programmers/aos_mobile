import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<File?> pickImageFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  if (result != null && result.files.isNotEmpty) {
    return File(result.files.first.path!);
  }
  return null;
}

Future<File?> pickVideoFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.video,
    allowMultiple: false,
  );
  if (result != null && result.files.isNotEmpty) {
    return File(result.files.first.path!);
  }
  return null;
}
