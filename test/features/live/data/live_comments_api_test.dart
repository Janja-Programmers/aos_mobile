import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../helpers/live_api_harness.dart';
import '../helpers/live_fixtures.dart';

void main() {
  test('comment submission sends content, session, and idempotency key', () async {
    final adapter = RecordingHttpClientAdapter((RequestOptions options) {
      return jsonResponse(
        successEnvelope(<String, dynamic>{
          'message': _messageJson(id: 'MESSAGE-001'),
        }),
      );
    });
    final harness = await buildLiveApiHarness(adapter);

    final result = await harness.commentsApi.addComment(
      liveId: testLiveId,
      comment: 'Hello Live',
      sessionId: testViewerSessionId,
      idempotencyKey: 'idempotency-001',
    );

    expect(result.rightOrNull?.id, 'MESSAGE-001');
    expect(adapter.singleRequest.path, ApiEndpoints.addLiveComment);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'live_id': testLiveId,
      'content': 'Hello Live',
      'session_id': testViewerSessionId,
      'idempotency_key': 'idempotency-001',
    });
  });

  test('comment history filters server-deleted rows', () async {
    final adapter = RecordingHttpClientAdapter((RequestOptions options) {
      return jsonResponse(
        successEnvelope(<String, dynamic>{
          'items': <Map<String, dynamic>>[
            _messageJson(id: 'MESSAGE-001'),
            _messageJson(id: 'MESSAGE-002', status: 'deleted'),
          ],
        }),
      );
    });
    final harness = await buildLiveApiHarness(adapter);

    final result = await harness.commentsApi.listComments(
      liveId: testLiveId,
      limit: 40,
    );

    expect(result.rightOrNull?.map((item) => item.id), <String>['MESSAGE-001']);
    expect(adapter.singleRequest.path, ApiEndpoints.listLiveComments);
    expect(adapter.singleRequest.queryParameters, <String, dynamic>{
      'live_id': testLiveId,
      'start': 0,
      'limit': 40,
    });
  });
}

Map<String, dynamic> _messageJson({
  required String id,
  String status = 'active',
}) {
  return <String, dynamic>{
    'message_id': id,
    'live_id': testLiveId,
    'user_id': 'ACC-2026-00002',
    'display_name': 'Test Viewer',
    'content': 'Hello Live',
    'message_kind': 'comment',
    'message_type': 'comment',
    'reply_count': 0,
    'status': status,
    'created_at': '2026-08-11T10:02:00Z',
  };
}
