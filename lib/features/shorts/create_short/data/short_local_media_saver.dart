import 'dart:io';

import 'package:gal/gal.dart';

abstract interface class ShortLocalMediaSaver {
  Future<void> saveVideo(String path);
}

final class GalShortLocalMediaSaver implements ShortLocalMediaSaver {
  const GalShortLocalMediaSaver();

  @override
  Future<void> saveVideo(String path) async {
    final cleanPath = path.trim();
    if (cleanPath.isEmpty || !File(cleanPath).existsSync()) {
      throw const FileSystemException('The video file is unavailable.');
    }

    final hasAccess = await Gal.hasAccess();
    final granted = hasAccess || await Gal.requestAccess();
    if (!granted) {
      throw const ShortGalleryAccessDenied();
    }
    await Gal.putVideo(cleanPath);
  }
}

class ShortGalleryAccessDenied implements Exception {
  const ShortGalleryAccessDenied();
}
