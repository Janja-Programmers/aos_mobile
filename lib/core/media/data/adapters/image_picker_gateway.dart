import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class PickerGatewayFile {
  const PickerGatewayFile({required this.path, required this.name});

  final String path;
  final String name;
}

class PickerGatewayLostData {
  const PickerGatewayLostData({
    this.files = const <PickerGatewayFile>[],
    this.errorDescription,
  });

  final List<PickerGatewayFile> files;
  final String? errorDescription;
}

abstract interface class ImagePickerGateway {
  Future<PickerGatewayFile?> pickSingleImage();

  Future<List<PickerGatewayFile>> pickMultipleImages({required int limit});

  Future<PickerGatewayFile?> pickSingleVideo();

  Future<PickerGatewayLostData> retrieveLostData();
}

class PluginImagePickerGateway implements ImagePickerGateway {
  PluginImagePickerGateway({ImagePicker? picker})
    : _picker = picker ?? ImagePicker() {
    _configureAndroidPhotoPicker();
  }

  final ImagePicker _picker;

  void _configureAndroidPhotoPicker() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final implementation = ImagePickerPlatform.instance;
    if (implementation is ImagePickerAndroid) {
      implementation.useAndroidPhotoPicker = true;
    }
  }

  @override
  Future<PickerGatewayFile?> pickSingleImage() async {
    final selected = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (selected == null) return null;
    return PickerGatewayFile(path: selected.path, name: selected.name);
  }

  @override
  Future<List<PickerGatewayFile>> pickMultipleImages({
    required int limit,
  }) async {
    final selected = await _picker.pickMultiImage(
      limit: limit,
      requestFullMetadata: false,
    );
    return selected
        .map((file) => PickerGatewayFile(path: file.path, name: file.name))
        .toList(growable: false);
  }

  @override
  Future<PickerGatewayFile?> pickSingleVideo() async {
    final selected = await _picker.pickVideo(source: ImageSource.gallery);
    if (selected == null) return null;
    return PickerGatewayFile(path: selected.path, name: selected.name);
  }

  @override
  Future<PickerGatewayLostData> retrieveLostData() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const PickerGatewayLostData();
    }

    final response = await _picker.retrieveLostData();
    return PickerGatewayLostData(
      files:
          response.files
              ?.map(
                (file) => PickerGatewayFile(path: file.path, name: file.name),
              )
              .toList(growable: false) ??
          const <PickerGatewayFile>[],
      errorDescription: response.exception?.toString(),
    );
  }
}
