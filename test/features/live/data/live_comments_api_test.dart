import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../helpers/live_api_harness.dart';
import '../helpers/live_fixtures.dart';

void main() {
  test(
    'comment submission sends content, session, and idempotency key',
    () async {
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
    },
  );

  test('reply submission uses canonical parent and idempotency key', () async {
    final adapter = RecordingHttpClientAdapter((RequestOptions options) {
      return jsonResponse(
        successEnvelope(<String, dynamic>{
          'message': _messageJson(
            id: 'MESSAGE-REPLY',
            messageType: 'reply',
            parentMessage: 'MESSAGE-PARENT',
          ),
        }),
      );
    });
    final harness = await buildLiveApiHarness(adapter);

    final result = await harness.commentsApi.replyComment(
      liveId: testLiveId,
      parentMessageId: 'MESSAGE-PARENT',
      comment: 'Reply',
      sessionId: testViewerSessionId,
      idempotencyKey: 'reply-idempotency-001',
    );

    expect(result.rightOrNull?.isReply, isTrue);
    expect(adapter.singleRequest.path, ApiEndpoints.replyLiveComment);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'live_id': testLiveId,
      'parent_message': 'MESSAGE-PARENT',
      'content': 'Reply',
      'session_id': testViewerSessionId,
      'idempotency_key': 'reply-idempotency-001',
    });
  });

  test(
    'comment history requests inline replies and cursor pagination',
    () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        return jsonResponse(
          successEnvelope(<String, dynamic>{
            'items': <Map<String, dynamic>>[
              _messageJson(id: 'MESSAGE-001'),
              _messageJson(id: 'MESSAGE-002', status: 'deleted'),
            ],
            'pagination': <String, dynamic>{
              'has_more': true,
              'next_cursor': 'cursor-next',
            },
          }),
        );
      });
      final harness = await buildLiveApiHarness(adapter);

      final result = await harness.commentsApi.listComments(
        liveId: testLiveId,
        limit: 40,
        cursor: 'cursor-current',
      );

      expect(result.rightOrNull?.items.map((item) => item.id), <String>[
        'MESSAGE-001',
      ]);
      expect(result.rightOrNull?.nextCursor, 'cursor-next');
      expect(result.rightOrNull?.hasMore, isTrue);
      expect(adapter.singleRequest.path, ApiEndpoints.listLiveComments);
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'live_id': testLiveId,
        'limit': 40,
        'include_replies': 1,
        'cursor': 'cursor-current',
      });
    },
  );

  test('reply history parses inline parent context', () async {
    final adapter = RecordingHttpClientAdapter((RequestOptions options) {
      return jsonResponse(
        successEnvelope(<String, dynamic>{
          'items': <Map<String, dynamic>>[
            _messageJson(
              id: 'MESSAGE-REPLY',
              messageType: 'reply',
              parentMessage: 'MESSAGE-PARENT',
              replyTo: <String, dynamic>{
                'message_id': 'MESSAGE-PARENT',
                'user': 'ACC-2026-00004',
                'display_name': 'Parent author',
                'avatar': '/files/parent.png',
                'is_verified': true,
                'content': 'Parent content',
              },
            ),
          ],
          'pagination': <String, dynamic>{
            'has_more': false,
            'next_cursor': null,
          },
        }),
      );
    });
    final harness = await buildLiveApiHarness(adapter);

    final result = await harness.commentsApi.listReplies(
      parentMessageId: 'MESSAGE-PARENT',
      limit: 25,
    );

    final reply = result.rightOrNull?.items.single;
    expect(reply?.replyTo?.displayName, 'Parent author');
    expect(reply?.replyTo?.isVerified, isTrue);
    expect(adapter.singleRequest.path, ApiEndpoints.listLiveReplies);
    expect(adapter.singleRequest.queryParameters, <String, dynamic>{
      'parent_message': 'MESSAGE-PARENT',
      'limit': 25,
    });
  });

  test(
    'delete returns all recursively deleted canonical message IDs',
    () async {
      final adapter = RecordingHttpClientAdapter((RequestOptions options) {
        return jsonResponse(
          successEnvelope(<String, dynamic>{
            'message_id': 'MESSAGE-PARENT',
            'deleted_message_ids': <String>['MESSAGE-PARENT', 'MESSAGE-CHILD'],
          }),
        );
      });
      final harness = await buildLiveApiHarness(adapter);

      final result = await harness.commentsApi.deleteComment(
        commentId: 'MESSAGE-PARENT',
      );

      expect(result.rightOrNull, <String>{'MESSAGE-PARENT', 'MESSAGE-CHILD'});
      expect(adapter.singleRequest.path, ApiEndpoints.deleteLiveComment);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'message_id': 'MESSAGE-PARENT',
      });
    },
  );
}

Map<String, dynamic> _messageJson({
  required String id,
  String status = 'active',
  String messageType = 'comment',
  String? parentMessage,
  Map<String, dynamic>? replyTo,
}) {
  return <String, dynamic>{
    'message_id': id,
    'live_id': testLiveId,
    'user': 'ACC-2026-00002',
    'display_name': 'Test Viewer',
    'avatar': '/files/viewer.png',
    'is_verified': false,
    'content': 'Hello Live',
    'message_kind': 'comment',
    'message_type': messageType,
    'parent_message': ?parentMessage,
    'root_message': ?parentMessage,
    'reply_count': 0,
    'reply_to': ?replyTo,
    'status': status,
    'creation': '2026-08-11T10:02:00Z',
  };
}
