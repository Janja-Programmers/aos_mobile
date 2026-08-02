import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_creator.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_viewer_state.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/short_status.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/caption.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mp4Url = 'https://media.example.com/shorts/final.mp4';
  const hlsUrl = 'https://media.example.com/shorts/master.m3u8';

  test('processed_file_url survives backend model mapping', () {
    final model = ShortModel.fromJson(<String, dynamic>{
      'id': 'SHORT-2026-00001',
      'status': 'ready',
      'visibility_status': 'visible',
      'content_mode': 'vibes',
      'audience': 'everyone',
      'allow_downloads': true,
      'is_ready': true,
      'playback_url': hlsUrl,
      'processed_file_url': mp4Url,
      'creator': <String, dynamic>{},
      'viewer_state': <String, dynamic>{},
    });

    final short = ShortMapper.toDomain(model);

    expect(short.processedFileUrl, mp4Url);
    expect(short.preferredPublicShareUrl, mp4Url);
  });

  group('Short.preferredPublicShareUrl', () {
    test('prefers MP4 when public downloads are allowed', () {
      final short = _short(
        processedFileUrl: mp4Url,
        playbackUrl: hlsUrl,
        allowDownloads: true,
      );

      expect(short.preferredPublicShareUrl, mp4Url);
    });

    test('prefers the playable stream when downloads are disabled', () {
      final short = _short(
        processedFileUrl: mp4Url,
        playbackUrl: hlsUrl,
        allowDownloads: false,
      );

      expect(short.preferredPublicShareUrl, hlsUrl);
    });

    test(
      'does not expose MP4 when downloads are disabled and HLS is absent',
      () {
        final short = _short(
          processedFileUrl: mp4Url,
          playbackUrl: '',
          allowDownloads: false,
        );

        expect(short.preferredPublicShareUrl, isNull);
      },
    );

    test('does not expose direct media for restricted audiences', () {
      final short = _short(
        processedFileUrl: mp4Url,
        playbackUrl: hlsUrl,
        allowDownloads: true,
        audience: 'friends',
      );

      expect(short.preferredPublicShareUrl, isNull);
    });

    test('falls back to the valid playable URL', () {
      final short = _short(
        processedFileUrl: 'not-a-url',
        playbackUrl: hlsUrl,
        allowDownloads: true,
      );

      expect(short.preferredPublicShareUrl, hlsUrl);
    });

    test('does not expose media before processing is ready', () {
      final short = _short(
        processedFileUrl: mp4Url,
        playbackUrl: hlsUrl,
        allowDownloads: true,
        isReady: false,
        status: ShortStatus.processing,
      );

      expect(short.preferredPublicShareUrl, isNull);
    });
  });
}

Short _short({
  required String playbackUrl,
  required String? processedFileUrl,
  required bool allowDownloads,
  String audience = 'everyone',
  bool isReady = true,
  ShortStatus status = ShortStatus.ready,
}) {
  return Short(
    id: const ShortId('SHORT-2026-00001'),
    playbackUrl: playbackUrl,
    processedFileUrl: processedFileUrl,
    durationSeconds: 10,
    contentMode: 'vibes',
    caption: Caption('Test short'),
    hashtags: const <String>[],
    status: status,
    audience: audience,
    allowDownloads: allowDownloads,
    isReady: isReady,
    creator: ShortCreator.empty(),
    metrics: ShortMetrics.initial(),
    viewerState: ShortViewerState.initial(),
  );
}
