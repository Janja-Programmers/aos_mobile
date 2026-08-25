import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class NativeImagePreparationAdapter {
  const NativeImagePreparationAdapter();

  Future<File?> compressToJpeg({
    required File source,
    required String destinationPath,
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    final output = await FlutterImageCompress.compressAndGetFile(
      source.path,
      destinationPath,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
      // ignore: avoid_redundant_argument_values
      format: CompressFormat.jpeg,
      // ignore: avoid_redundant_argument_values
      keepExif: false,
    );
    return output == null ? null : File(output.path);
  }
}
