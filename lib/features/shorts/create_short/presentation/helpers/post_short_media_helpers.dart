import 'dart:io';
import 'dart:typed_data';

import 'package:video_thumbnail/video_thumbnail.dart';

class PostShortMediaHelpers {
  PostShortMediaHelpers._();

  /// Generate thumbnail for video
  static Future<Uint8List?> generateVideoThumbnail(File file) async {
    return VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      quality: 75,
      maxWidth: 300,
    );
  }
}
