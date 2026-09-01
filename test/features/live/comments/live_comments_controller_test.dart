import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_api.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_controller.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../helpers/live_api_harness.dart';
import '../helpers/live_fixtures.dart';

void main() {
  late LiveApiHarness harness;
  late _ScriptedLiveCommentsApi api;
  late LiveCommentsController controller;

  setUp(() async {
    harness = await buildLiveApiHarness(
      RecordingHttpClientAdapter((_) => jsonResponse(<String, dynamic>{})),
    );
    api = _ScriptedLiveCommentsApi(harness.client);
    controller = LiveCommentsController(api);
  });

  tearDown(() => controller.dispose());

  test('a stale fetch cannot replace comments for a newer Live', () async {
    final firstResponse = Completer<Either<Failure, LiveCommentsPage>>();
    final secondResponse = Completer<Either<Failure, LiveCommentsPage>>();
    api.listResponses[testLiveId] = firstResponse;
    api.listResponses[secondTestLiveId] = secondResponse;

    final first = controller.fetchComments(testLiveId);
    await Future<void>.delayed(Duration.zero);
    controller.resetForLive(secondTestLiveId);
    final second = controller.fetchComments(secondTestLiveId);

    secondResponse.complete(
      Either.right(
        LiveCommentsPage(
          items: <LiveComment>[
            _comment(id: 'MESSAGE-002', liveId: secondTestLiveId),
          ],
          nextCursor: null,
          hasMore: false,
        ),
      ),
    );
    await second;
    firstResponse.complete(
      Either.right(
        LiveCommentsPage(
          items: <LiveComment>[_comment(id: 'MESSAGE-001', liveId: testLiveId)],
          nextCursor: null,
          hasMore: false,
        ),
      ),
    );
    await first;

    expect(controller.state.liveId, secondTestLiveId);
    expect(controller.state.comments.map((item) => item.id), <String>[
      'MESSAGE-002',
    ]);
    expect(controller.state.isLoading, isFalse);
  });

  test('history requests replies and uses cursor pagination', () async {
    api.listResponses[testLiveId] =
        Completer<Either<Failure, LiveCommentsPage>>()..complete(
          Either.right(
            LiveCommentsPage(
              items: <LiveComment>[
                _comment(id: 'MESSAGE-001', liveId: testLiveId),
              ],
              nextCursor: 'cursor-2',
              hasMore: true,
            ),
          ),
        );

    await controller.fetchComments(testLiveId);

    expect(api.listRequests.single.includeReplies, isTrue);
    expect(api.listRequests.single.cursor, isNull);
    expect(controller.state.nextCursor, 'cursor-2');

    api.listResponses[testLiveId] =
        Completer<Either<Failure, LiveCommentsPage>>()..complete(
          Either.right(
            LiveCommentsPage(
              items: <LiveComment>[
                _comment(id: 'MESSAGE-000', liveId: testLiveId),
              ],
              nextCursor: null,
              hasMore: false,
            ),
          ),
        );

    await controller.loadMore();

    expect(api.listRequests.last.cursor, 'cursor-2');
    expect(api.listRequests.last.includeReplies, isTrue);
    expect(controller.state.comments.map((item) => item.id), <String>[
      'MESSAGE-001',
      'MESSAGE-000',
    ]);
    expect(controller.state.hasMore, isFalse);
  });

  test('realtime insert is deduplicated and deletion is tombstoned', () {
    controller.resetForLive(testLiveId);
    final payload = <String, dynamic>{
      'live_id': testLiveId,
      'message': <String, dynamic>{
        'message_id': 'MESSAGE-003',
        'live_id': testLiveId,
        'user': 'ACC-2026-00002',
        'display_name': 'Viewer',
        'avatar': '/files/viewer.png',
        'is_verified': true,
        'content': 'Hello Live',
        'message_kind': 'comment',
        'message_type': 'comment',
        'creation': '2026-08-11T10:02:00Z',
      },
    };

    controller.insertFromRealtime(payload);
    controller.insertFromRealtime(payload);
    expect(controller.state.comments, hasLength(1));
    expect(controller.state.comments.single.avatarUrl, '/files/viewer.png');

    controller.removeFromRealtime('MESSAGE-003');
    controller.insertFromRealtime(payload);

    expect(controller.state.comments, isEmpty);
  });

  test('repeated reply submissions issue one idempotent mutation', () async {
    controller.resetForLive(testLiveId);
    final response = Completer<Either<Failure, LiveComment>>();
    api.replyResponse = response;

    final first = controller.replyComment(
      liveId: testLiveId,
      parentMessageId: 'MESSAGE-PARENT',
      comment: '  Reply once  ',
      sessionId: testViewerSessionId,
    );
    final second = controller.replyComment(
      liveId: testLiveId,
      parentMessageId: 'MESSAGE-PARENT',
      comment: 'Duplicate tap',
      sessionId: testViewerSessionId,
    );

    expect(await second, isFalse);
    expect(api.replyRequests, hasLength(1));
    expect(api.replyRequests.single.comment, 'Reply once');
    expect(api.replyRequests.single.parentMessageId, 'MESSAGE-PARENT');
    expect(api.replyRequests.single.idempotencyKey, isNotEmpty);

    response.complete(
      Either.right(
        _comment(
          id: 'MESSAGE-004',
          liveId: testLiveId,
          parentId: 'MESSAGE-PARENT',
          messageType: 'reply',
        ),
      ),
    );
    expect(await first, isTrue);
    expect(controller.state.comments.single.id, 'MESSAGE-004');
    expect(controller.state.isSubmitting, isFalse);
  });

  test('failed optimistic deletion restores the removed branch', () async {
    controller.resetForLive(testLiveId);
    controller.insertFromRealtime(<String, dynamic>{
      'live_id': testLiveId,
      'message': <String, dynamic>{
        'message_id': 'MESSAGE-005',
        'live_id': testLiveId,
        'user': 'ACC-2026-00002',
        'content': 'Parent',
        'message_kind': 'comment',
        'message_type': 'comment',
        'creation': '2026-08-11T10:03:00Z',
      },
    });
    controller.insertFromRealtime(<String, dynamic>{
      'live_id': testLiveId,
      'message': <String, dynamic>{
        'message_id': 'MESSAGE-006',
        'live_id': testLiveId,
        'user': 'ACC-2026-00003',
        'content': 'Child',
        'message_kind': 'comment',
        'message_type': 'reply',
        'parent_message': 'MESSAGE-005',
        'creation': '2026-08-11T10:03:01Z',
      },
    });
    api.deleteResult = Either.left(
      const Failure('Deletion denied.', error: 'FORBIDDEN'),
    );

    final deleted = await controller.deleteComment(commentId: 'MESSAGE-005');

    expect(deleted, isFalse);
    expect(controller.state.comments.map((item) => item.id).toSet(), {
      'MESSAGE-005',
      'MESSAGE-006',
    });
    expect(controller.state.errorMessage, 'Deletion denied.');
  });

  test(
    'successful deletion tombstones backend-recursive descendants',
    () async {
      controller.resetForLive(testLiveId);
      controller.insertFromRealtime(<String, dynamic>{
        'live_id': testLiveId,
        'message': <String, dynamic>{
          'message_id': 'MESSAGE-010',
          'live_id': testLiveId,
          'user': 'ACC-2026-00002',
          'content': 'Parent',
          'message_kind': 'comment',
          'message_type': 'comment',
          'creation': '2026-08-11T10:05:00Z',
        },
      });
      api.deleteResult = Either.right(<String>{'MESSAGE-010', 'MESSAGE-011'});

      expect(await controller.deleteComment(commentId: 'MESSAGE-010'), isTrue);

      controller.insertFromRealtime(<String, dynamic>{
        'live_id': testLiveId,
        'message': <String, dynamic>{
          'message_id': 'MESSAGE-011',
          'live_id': testLiveId,
          'user': 'ACC-2026-00003',
          'content': 'Late recursive child event',
          'message_kind': 'comment',
          'message_type': 'reply',
          'parent_message': 'MESSAGE-010',
          'creation': '2026-08-11T10:05:01Z',
        },
      });

      expect(controller.state.comments, isEmpty);
    },
  );
}

LiveComment _comment({
  required String id,
  required String liveId,
  String? parentId,
  String messageType = 'comment',
}) {
  return LiveComment(
    id: id,
    liveId: liveId,
    userId: 'ACC-2026-00002',
    displayName: 'Viewer',
    avatarUrl: '/files/viewer.png',
    isVerified: false,
    comment: 'Test comment',
    messageKind: 'comment',
    messageType: messageType,
    parentId: parentId,
    rootId: parentId,
    replyCount: 0,
    replyTo: null,
    isDeleted: false,
    createdAt: DateTime.utc(2026, 8, 11, 10, 2),
  );
}

class _ScriptedLiveCommentsApi extends LiveCommentsApi {
  _ScriptedLiveCommentsApi(super.client);

  final Map<String, Completer<Either<Failure, LiveCommentsPage>>>
  listResponses = <String, Completer<Either<Failure, LiveCommentsPage>>>{};
  final List<({String liveId, String? cursor, bool includeReplies})>
  listRequests = <({String liveId, String? cursor, bool includeReplies})>[];
  final List<
    ({String liveId, String comment, String? sessionId, String idempotencyKey})
  >
  addRequests =
      <
        ({
          String liveId,
          String comment,
          String? sessionId,
          String idempotencyKey,
        })
      >[];
  final List<
    ({
      String liveId,
      String parentMessageId,
      String comment,
      String? sessionId,
      String idempotencyKey,
    })
  >
  replyRequests =
      <
        ({
          String liveId,
          String parentMessageId,
          String comment,
          String? sessionId,
          String idempotencyKey,
        })
      >[];
  Completer<Either<Failure, LiveComment>>? addResponse;
  Completer<Either<Failure, LiveComment>>? replyResponse;
  Either<Failure, Set<String>> deleteResult = Either.right(<String>{});

  @override
  Future<Either<Failure, LiveCommentsPage>> listComments({
    required String liveId,
    int limit = 50,
    String? cursor,
    bool includeReplies = true,
  }) {
    listRequests.add((
      liveId: liveId,
      cursor: cursor,
      includeReplies: includeReplies,
    ));
    final response = listResponses[liveId];
    if (response == null) {
      throw StateError('Missing comments response for $liveId.');
    }
    return response.future;
  }

  @override
  Future<Either<Failure, LiveComment>> addComment({
    required String liveId,
    required String comment,
    String? sessionId,
    String? idempotencyKey,
  }) {
    addRequests.add((
      liveId: liveId,
      comment: comment,
      sessionId: sessionId,
      idempotencyKey: idempotencyKey ?? '',
    ));
    final response = addResponse;
    if (response == null) throw StateError('Missing add comment response.');
    return response.future;
  }

  @override
  Future<Either<Failure, LiveComment>> replyComment({
    required String liveId,
    required String parentMessageId,
    required String comment,
    String? sessionId,
    String? idempotencyKey,
  }) {
    replyRequests.add((
      liveId: liveId,
      parentMessageId: parentMessageId,
      comment: comment,
      sessionId: sessionId,
      idempotencyKey: idempotencyKey ?? '',
    ));
    final response = replyResponse;
    if (response == null) throw StateError('Missing reply response.');
    return response.future;
  }

  @override
  Future<Either<Failure, Set<String>>> deleteComment({
    required String commentId,
  }) async {
    return deleteResult;
  }
}
