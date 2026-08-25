import 'dart:convert';
import 'dart:io';

import 'package:africaonlinestores/core/media/domain/media_asset.dart';

class DetectedMediaType {
  const DetectedMediaType({required this.kind, required this.contentType});

  final MediaKind kind;
  final String contentType;
}

class MediaTypeDetector {
  const MediaTypeDetector();

  Future<DetectedMediaType> detect(File file) async {
    final extension = mediaExtension(file.path);
    final header = await _readHeader(file, 32);

    if (_startsWith(header, const <int>[0xFF, 0xD8, 0xFF])) {
      return const DetectedMediaType(
        kind: MediaKind.image,
        contentType: 'image/jpeg',
      );
    }
    if (_startsWith(header, const <int>[
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
    ])) {
      return const DetectedMediaType(
        kind: MediaKind.image,
        contentType: 'image/png',
      );
    }
    if (_ascii(header, 0, 4) == 'RIFF' && _ascii(header, 8, 4) == 'WEBP') {
      return const DetectedMediaType(
        kind: MediaKind.image,
        contentType: 'image/webp',
      );
    }
    if (_ascii(header, 0, 4) == '%PDF') {
      return const DetectedMediaType(
        kind: MediaKind.document,
        contentType: 'application/pdf',
      );
    }
    if (_ascii(header, 4, 4) == 'ftyp') {
      final brand = _ascii(header, 8, 4).toLowerCase();
      const heifBrands = <String>{
        'heic',
        'heix',
        'hevc',
        'hevx',
        'mif1',
        'msf1',
      };
      if (extension == 'heic' ||
          extension == 'heif' ||
          heifBrands.contains(brand)) {
        return const DetectedMediaType(
          kind: MediaKind.image,
          contentType: 'image/heic',
        );
      }
      if (extension == 'm4a') {
        return const DetectedMediaType(
          kind: MediaKind.audio,
          contentType: 'audio/mp4',
        );
      }
      return DetectedMediaType(
        kind: MediaKind.video,
        contentType: extension == 'mov' ? 'video/quicktime' : 'video/mp4',
      );
    }
    if (_ascii(header, 0, 4) == 'RIFF' && _ascii(header, 8, 4) == 'WAVE') {
      return const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/wav',
      );
    }
    if (_ascii(header, 0, 4) == 'OggS') {
      return const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/ogg',
      );
    }
    if (_ascii(header, 0, 4) == 'fLaC') {
      return const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/flac',
      );
    }
    if (_ascii(header, 0, 3) == 'ID3') {
      return const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/mpeg',
      );
    }
    if (header.length >= 2 && header[0] == 0xFF && (header[1] & 0xE0) == 0xE0) {
      return DetectedMediaType(
        kind: MediaKind.audio,
        contentType: extension == 'aac' ? 'audio/aac' : 'audio/mpeg',
      );
    }

    return _fromExtension(extension);
  }

  Future<List<int>> _readHeader(File file, int length) async {
    final reader = await file.open();
    try {
      final header = await reader.read(length);
      return header;
    } finally {
      await reader.close();
    }
  }

  bool _startsWith(List<int> value, List<int> signature) {
    if (value.length < signature.length) return false;
    for (var index = 0; index < signature.length; index += 1) {
      if (value[index] != signature[index]) return false;
    }
    return true;
  }

  String _ascii(List<int> value, int offset, int length) {
    if (value.length < offset + length) return '';
    return ascii.decode(
      value.sublist(offset, offset + length),
      allowInvalid: true,
    );
  }

  DetectedMediaType _fromExtension(String extension) {
    return switch (extension) {
      'jpg' || 'jpeg' => const DetectedMediaType(
        kind: MediaKind.image,
        contentType: 'image/jpeg',
      ),
      'png' => const DetectedMediaType(
        kind: MediaKind.image,
        contentType: 'image/png',
      ),
      'webp' => const DetectedMediaType(
        kind: MediaKind.image,
        contentType: 'image/webp',
      ),
      'heic' || 'heif' => const DetectedMediaType(
        kind: MediaKind.image,
        contentType: 'image/heic',
      ),
      'mp4' || 'm4v' => const DetectedMediaType(
        kind: MediaKind.video,
        contentType: 'video/mp4',
      ),
      'webm' => const DetectedMediaType(
        kind: MediaKind.video,
        contentType: 'video/webm',
      ),
      'mov' => const DetectedMediaType(
        kind: MediaKind.video,
        contentType: 'video/quicktime',
      ),
      'mp3' => const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/mpeg',
      ),
      'm4a' => const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/mp4',
      ),
      'aac' => const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/aac',
      ),
      'wav' => const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/wav',
      ),
      'ogg' || 'opus' => const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/ogg',
      ),
      'flac' => const DetectedMediaType(
        kind: MediaKind.audio,
        contentType: 'audio/flac',
      ),
      'pdf' => const DetectedMediaType(
        kind: MediaKind.document,
        contentType: 'application/pdf',
      ),
      _ => const DetectedMediaType(
        kind: MediaKind.file,
        contentType: 'application/octet-stream',
      ),
    };
  }
}
