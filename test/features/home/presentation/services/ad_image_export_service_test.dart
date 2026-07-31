// ignore_for_file: avoid_slow_async_io

import 'dart:io';
import 'dart:typed_data';

import 'package:africaonlinestores/features/home/presentation/services/ad_image_export_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';

void main() {
  group('AdImageExportService', () {
    test(
      'downloads an image, saves it to gallery, then removes temp file',
      () async {
        final adapter = RecordingHttpClientAdapter((options) {
          return ResponseBody.fromBytes(
            <int>[1, 2, 3, 4],
            200,
            headers: const <String, List<String>>{
              Headers.contentTypeHeader: <String>['image/png'],
              Headers.contentLengthHeader: <String>['4'],
            },
          );
        });
        final dio = Dio()..httpClientAdapter = adapter;
        final writer = _RecordingGalleryWriter(hasAccessValue: true);
        final service = AdImageExportService(dio, galleryWriter: writer);

        await service.saveImageToGallery(
          imageUrl: 'https://cdn.example.invalid/ad-image.png',
        );

        expect(
          adapter.singleRequest.uri.toString(),
          'https://cdn.example.invalid/ad-image.png',
        );
        expect(adapter.singleRequest.headers['Accept'], 'image/*,*/*;q=0.8');
        expect(writer.requestAccessCalls, 0);
        expect(writer.savedMediaType, AdGalleryMediaType.image);
        expect(writer.savedPath, endsWith('.png'));
        expect(writer.savedBytes, Uint8List.fromList(<int>[1, 2, 3, 4]));
        expect(await File(writer.savedPath!).exists(), isFalse);
      },
    );

    test('requests gallery access before downloading when needed', () async {
      final adapter = RecordingHttpClientAdapter((options) {
        return ResponseBody.fromBytes(<int>[7], 200);
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final writer = _RecordingGalleryWriter(hasAccessValue: false);
      final service = AdImageExportService(dio, galleryWriter: writer);

      await service.saveImageToGallery(
        imageUrl: 'https://cdn.example.invalid/ad-image.jpg',
      );

      expect(writer.requestAccessCalls, 1);
      expect(adapter.requests, hasLength(1));
      expect(writer.savedMediaType, AdGalleryMediaType.image);
    });

    test('does not download when gallery access is denied', () async {
      final adapter = RecordingHttpClientAdapter((options) {
        return ResponseBody.fromBytes(<int>[7], 200);
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final writer = _RecordingGalleryWriter(
        hasAccessValue: false,
        requestAccessValue: false,
      );
      final service = AdImageExportService(dio, galleryWriter: writer);

      await expectLater(
        service.saveImageToGallery(
          imageUrl: 'https://cdn.example.invalid/ad-image.jpg',
        ),
        throwsA(
          isA<AdImageExportException>().having(
            (error) => error.message,
            'message',
            contains('Gallery access was denied'),
          ),
        ),
      );

      expect(adapter.requests, isEmpty);
      expect(writer.savedPath, isNull);
    });

    test(
      'supports video gallery saves for the shared download service',
      () async {
        final adapter = RecordingHttpClientAdapter((options) {
          return ResponseBody.fromBytes(<int>[9, 8], 200);
        });
        final dio = Dio()..httpClientAdapter = adapter;
        final writer = _RecordingGalleryWriter(hasAccessValue: true);
        final service = AdImageExportService(dio, galleryWriter: writer);

        await service.saveVideoToGallery(
          videoUrl: 'https://cdn.example.invalid/ad-video.mp4',
        );

        expect(adapter.singleRequest.headers['Accept'], 'video/*,*/*;q=0.8');
        expect(writer.savedMediaType, AdGalleryMediaType.video);
        expect(writer.savedPath, endsWith('.mp4'));
        expect(await File(writer.savedPath!).exists(), isFalse);
      },
    );

    test('maps a missing remote image to a stable user-facing error', () async {
      final adapter = RecordingHttpClientAdapter((options) {
        return ResponseBody.fromString('missing', 404);
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final writer = _RecordingGalleryWriter(hasAccessValue: true);
      final service = AdImageExportService(dio, galleryWriter: writer);

      await expectLater(
        service.saveImageToGallery(
          imageUrl: 'https://cdn.example.invalid/missing.jpg',
        ),
        throwsA(
          isA<AdImageExportException>().having(
            (error) => error.message,
            'message',
            contains('could not be found'),
          ),
        ),
      );

      expect(writer.savedPath, isNull);
    });
  });
}

final class _RecordingGalleryWriter implements AdGalleryWriter {
  _RecordingGalleryWriter({
    required this.hasAccessValue,
    this.requestAccessValue = true,
  });

  final bool hasAccessValue;
  final bool requestAccessValue;

  int requestAccessCalls = 0;
  String? savedPath;
  Uint8List? savedBytes;
  AdGalleryMediaType? savedMediaType;

  @override
  Future<bool> hasAccess() async => hasAccessValue;

  @override
  Future<bool> requestAccess() async {
    requestAccessCalls += 1;
    return requestAccessValue;
  }

  @override
  Future<void> save({
    required String filePath,
    required AdGalleryMediaType mediaType,
  }) async {
    savedPath = filePath;
    savedMediaType = mediaType;
    savedBytes = await File(filePath).readAsBytes();
  }
}
