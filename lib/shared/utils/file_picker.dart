import 'dart:io';
import 'package:image_picker/image_picker.dart';

final _picker = ImagePicker();

Future<File?> pickImageFile() async {
  final XFile? pickedFile = await _picker.pickImage(
    source: ImageSource.gallery,
  );
  return pickedFile != null ? File(pickedFile.path) : null;
}

Future<File?> pickVideoFile() async {
  final XFile? pickedFile = await _picker.pickVideo(
    source: ImageSource.gallery,
  );
  return pickedFile != null ? File(pickedFile.path) : null;
}
