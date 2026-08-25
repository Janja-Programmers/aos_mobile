import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_type_detector.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'detects content from signatures rather than a misleading extension',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'media-type-test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/not_really_text.txt');
      await file.writeAsBytes(<int>[0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

      const detector = MediaTypeDetector();
      final detected = await detector.detect(file);

      expect(detected.kind, MediaKind.image);
      expect(detected.contentType, 'image/jpeg');
    },
  );

  test('recognizes PDF documents', () async {
    final directory = await Directory.systemTemp.createTemp('media-pdf-test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/document.pdf');
    await file.writeAsString('%PDF-1.7');

    const detector = MediaTypeDetector();
    final detected = await detector.detect(file);

    expect(detected.kind, MediaKind.document);
    expect(detected.contentType, 'application/pdf');
  });

  test('keeps an MP4-container M4A file classified as audio', () async {
    final directory = await Directory.systemTemp.createTemp('media-m4a-test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/sound.m4a');
    await file.writeAsBytes(<int>[
      0x00,
      0x00,
      0x00,
      0x18,
      0x66,
      0x74,
      0x79,
      0x70,
      0x4D,
      0x34,
      0x41,
      0x20,
    ]);

    const detector = MediaTypeDetector();
    final detected = await detector.detect(file);

    expect(detected.kind, MediaKind.audio);
    expect(detected.contentType, 'audio/mp4');
  });

  test('an ID3 signature remains MP3 despite a misleading extension', () async {
    final directory = await Directory.systemTemp.createTemp('media-mp3-test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/renamed.aac');
    await file.writeAsBytes(<int>[0x49, 0x44, 0x33, 0x04, 0x00]);

    const detector = MediaTypeDetector();
    final detected = await detector.detect(file);

    expect(detected.kind, MediaKind.audio);
    expect(detected.contentType, 'audio/mpeg');
  });
}
