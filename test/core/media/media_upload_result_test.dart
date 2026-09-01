import 'package:africaonlinestores/core/media/domain/media_upload_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses direct upload contract', () {
    final result = MediaUploadInitResponse.fromJson(<String, dynamic>{
      'media_id': 'MEDIA-1',
      'upload_mode': 'direct',
      'upload_url': 'https://storage.example/upload',
      'upload_headers': <String, dynamic>{'Content-Type': 'video/mp4'},
      'expires_in': 3600,
      'media': <String, dynamic>{
        'id': 'MEDIA-1',
        'purpose': 'short_video_raw',
        'status': 'Uploading',
        'visibility': 'Private',
        'original_filename': 'clip.mp4',
        'content_type': 'video/mp4',
        'size_bytes': 100,
      },
    });

    expect(result.isDirect, isTrue);
    expect(result.isMultipart, isFalse);
    expect(result.uploadUrl, isNotEmpty);
  });

  test('parses resumable multipart upload contract', () {
    final result = MediaUploadInitResponse.fromJson(<String, dynamic>{
      'media_id': 'MEDIA-2',
      'upload_contract_version': 1,
      'upload_mode': 'multipart',
      'upload_url': null,
      'upload_headers': <String, dynamic>{},
      'expires_in': 0,
      'multipart': <String, dynamic>{
        'contract_version': 1,
        'session_id': 'MEDIA-2',
        'part_size_bytes': 8388608,
        'part_count': 3,
        'part_url_batch_size': 2,
        'max_parallel_parts': 2,
        'part_url_expires_in': 3600,
        'session_expires_in': 86400,
      },
      'media': <String, dynamic>{
        'id': 'MEDIA-2',
        'purpose': 'short_video_raw',
        'status': 'Uploading',
        'visibility': 'Private',
        'original_filename': 'large.mp4',
        'content_type': 'video/mp4',
        'size_bytes': 188743680,
      },
    });

    expect(result.isMultipart, isTrue);
    expect(result.multipart, isNotNull);
    expect(result.multipart!.partSizeBytes, 8388608);
    expect(result.multipart!.maxParallelParts, 2);
    expect(result.multipart!.isValid, isTrue);
  });
}
