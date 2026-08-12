import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../helpers/live_api_harness.dart';
import '../helpers/live_fixtures.dart';

void main() {
  group('LiveApi start and join', () {
    test('start sends only normalized backend-supported fields', () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        return jsonResponse(
          successEnvelope(bootstrapData(role: 'host')),
        );
      });
      final harness = await buildLiveApiHarness(adapter);

      final result = await harness.liveApi.startLive(
        title: '  Test Live  ',
        coverImage: ' https://cdn.example.invalid/ignored.jpg ',
        coverMediaId: ' MEDIA-LIVE-001 ',
      );

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.method, 'POST');
      expect(adapter.singleRequest.path, ApiEndpoints.startLiveEndpoint);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'title': 'Test Live',
        'live_cover_media': 'MEDIA-LIVE-001',
      });
    });

    test('start omits an absent optional cover', () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        return jsonResponse(
          successEnvelope(bootstrapData(role: 'host')),
        );
      });
      final harness = await buildLiveApiHarness(adapter);

      await harness.liveApi.startLive(title: 'Test Live');

      expect(adapter.singleRequest.data, <String, dynamic>{
        'title': 'Test Live',
      });
    });

    test('join preserves caller session and fills a missing response value', () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        return jsonResponse(
          successEnvelope(bootstrapData(includeSessionId: false)),
        );
      });
      final harness = await buildLiveApiHarness(adapter);

      final result = await harness.liveApi.joinLive(
        liveId: testLiveId,
        sessionId: ' existing-session ',
      );

      expect(adapter.singleRequest.path, ApiEndpoints.joinLiveEndpoint);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'live_id': testLiveId,
        'session_id': 'existing-session',
      });
      expect(result.rightOrNull?.session.sessionId, 'existing-session');
    });

    test('malformed bootstrap becomes a typed parse failure', () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        return jsonResponse(
          successEnvelope(<String, dynamic>{'live': liveJson()}),
        );
      });
      final harness = await buildLiveApiHarness(adapter);

      final result = await harness.liveApi.joinLive(liveId: testLiveId);

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull?.message, 'Invalid join Live response.');
    });
  });

  group('LiveApi actions', () {
    test('reaction uses canonical value and session identifier', () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        return jsonResponse(
          successEnvelope(<String, dynamic>{
            'reaction': <String, dynamic>{
              'reaction_id': 'REACTION-001',
              'live_id': testLiveId,
              'reaction_type': 'wow',
              'created_at': '2026-08-11T10:01:00Z',
            },
          }),
        );
      });
      final harness = await buildLiveApiHarness(adapter);

      final result = await harness.liveApi.sendReaction(
        liveId: testLiveId,
        reactionType: LiveReactionType.wow,
        sessionId: testViewerSessionId,
      );

      expect(result.rightOrNull?.type, LiveReactionType.wow);
      expect(adapter.singleRequest.path, ApiEndpoints.sendLiveReaction);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'live_id': testLiveId,
        'reaction_type': 'wow',
        'session_id': testViewerSessionId,
      });
    });

    test('chat sharing sends no empty optional fields', () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        return jsonResponse(successEnvelope(<String, dynamic>{}));
      });
      final harness = await buildLiveApiHarness(adapter);

      final result = await harness.liveApi.shareLiveToChat(
        liveId: testLiveId,
        conversationId: 'CONV-2026-00001',
        message: '   ',
      );

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.path, ApiEndpoints.shareLiveToChat);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'live_id': testLiveId,
        'conversation_id': 'CONV-2026-00001',
      });
    });
  });
}
