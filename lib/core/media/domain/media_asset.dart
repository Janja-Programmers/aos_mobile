// ignore_for_file: avoid_slow_async_io

import 'dart:io';

enum MediaKind { image, video, audio, document, file }

enum MediaAcquisitionSource { camera, gallery, fileSystem, recorder, generated }

enum MediaCameraFacing { front, rear }

enum MediaCameraOwner { sharedCapture, shorts, live }

class MediaAcquisitionException implements Exception {
  const MediaAcquisitionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MediaPolicyException implements Exception {
  const MediaPolicyException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AcquiredMedia {
  const AcquiredMedia({
    required this.file,
    required this.kind,
    required this.source,
    required this.originalName,
    required this.ownedByApp,
  });

  factory AcquiredMedia.external({
    required File file,
    required MediaKind kind,
    MediaAcquisitionSource source = MediaAcquisitionSource.generated,
  }) {
    return AcquiredMedia(
      file: file,
      kind: kind,
      source: source,
      originalName: mediaFilename(file.path),
      ownedByApp: false,
    );
  }

  final File file;
  final MediaKind kind;
  final MediaAcquisitionSource source;
  final String originalName;
  final bool ownedByApp;

  String get path => file.path;

  Future<void> discard() async {
    if (!ownedByApp) return;
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Temporary-file cleanup is best effort.
    }
  }
}

class PreparedMedia {
  const PreparedMedia({
    required this.file,
    required this.kind,
    required this.contentType,
    required this.sizeBytes,
    required this.ownedByPreparation,
  });

  final File file;
  final MediaKind kind;
  final String contentType;
  final int sizeBytes;
  final bool ownedByPreparation;

  Future<void> discard() async {
    if (!ownedByPreparation) return;
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Temporary-file cleanup is best effort.
    }
  }
}

String mediaFilename(String path) {
  final normalized = path.replaceAll('\\', '/');
  final segments = normalized.split('/');
  final filename = segments.isEmpty ? '' : segments.last.trim();
  return filename.isEmpty ? 'media.bin' : filename;
}

String mediaExtension(String path) {
  final filename = mediaFilename(path).toLowerCase().split('?').first;
  final dot = filename.lastIndexOf('.');
  return dot < 0 ? '' : filename.substring(dot + 1);
}
