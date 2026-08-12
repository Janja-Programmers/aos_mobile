import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_api.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_controller.dart';
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
    final firstResponse = Completer<Either<Failure, List<LiveComment>>>();
    final secondResponse = Completer<Either<Failure, List<LiveComment>>>();
    api.listResponses[testLiveId] = firstResponse;
    api.listResponses[secondTestLiveId] = secondResponse;

    final first = controller.fetchComments(testLiveId);
    await Future<void>.delayed(Duration.zero);
    controller.resetForLive(secondTestLiveId);
    final second = controller.fetchComments(secondTestLiveId);

    secondResponse.complete(
      Either.right(<LiveComment>[
        _comment(id: 'MESSAGE-002', liveId: secondTestLiveId),
      ]),
    );
    await second;
    firstResponse.complete(
      Either.right(<LiveComment>[
        _comment(id: 'MESSAGE-001', liveId: testLiveId),
      ]),
    );
    await first;

    expect(controller.state.liveId, secondTestLiveId);
    expect(
      controller.state.comments.map((item) => item.id),
      <String>['MESSAGE-002'],
    );
    expect(controller.state.isLoading, isFalse);
  });

  test('realtime insert is deduplicated and deletion is tombstoned', () {
    controller.resetForLive(testLiveId);
    final payload = <String, dynamic>{
      'live_id': testLiveId,
      'message': <String, dynamic>{
        'message_id': 'MESSAGE-003',
        'live_id': testLiveId,
        'user_id': 'ACC-2026-00002',
        'display_name': 'Viewer',
        'content': 'Hello Live',
        'message_kind': 'comment',
        'created_at': '2026-08-11T10:02:00Z',
      },
    };

    controller.insertFromRealtime(payload);
    controller.insertFromRealtime(payload);
    expect(controller.state.comments, hasLength(1));

    controller.removeFromRealtime('MESSAGE-003');
    controller.insertFromRealtime(payload);

    expect(controller.state.comments, isEmpty);
  });

  test('repeated comment submissions issue one mutation', () async {
    controller.resetForLive(testLiveId);
    final response = Completer<Either<Failure, LiveComment>>();
    api.addResponse = response;

    final first = controller.addComment(
      liveId: testLiveId,
      comment: '  Hello Live  ',
      sessionId: testViewerSessionId,
    );
    final second = controller.addComment(
      liveId: testLiveId,
      comment: 'Second tap',
      sessionId: testViewerSessionId,
    );

    expect(await second, isFalse);
    expect(api.addRequests, hasLength(1));
    expect(api.addRequests.single.comment, 'Hello Live');
    expect(api.addRequests.single.sessionId, testViewerSessionId);
    expect(api.addRequests.single.idempotencyKey, isNotEmpty);

    response.complete(
      Either.right(_comment(id: 'MESSAGE-004', liveId: testLiveId)),
    );
    expect(await first, isTrue);
    expect(controller.state.comments.single.id, 'MESSAGE-004');
    expect(controller.state.isSubmitting, isFalse);
  });

  test('failed optimistic deletion restores the removed comment', () async {
    controller.resetForLive(testLiveId);
    controller.insertFromRealtime(<String, dynamic>{
      'live_id': testLiveId,
      'message': <String, dynamic>{
        'message_id': 'MESSAGE-005',
        'live_id': testLiveId,
        'user_id': 'ACC-2026-00002',
        'content': 'Keep me',
        'created_at': '2026-08-11T10:03:00Z',
      },
    });
    api.deleteResult = Either.left(
      const Failure('Deletion denied.', error: 'LIVE_ACCESS_DENIED'),
    );

    await controller.deleteComment(commentId: 'MESSAGE-005');

    expect(controller.state.comments.single.id, 'MESSAGE-005');
    expect(controller.state.errorMessage, 'Deletion denied.');
  });
}

LiveComment _comment({required String id, required String liveId}) {
  return LiveComment(
    id: id,
    liveId: liveId,
    userId: 'ACC-2026-00002',
    displayName: 'Viewer',
    comment: 'Test comment',
    messageKind: 'comment',
    messageType: 'comment',
    parentId: null,
    rootId: null,
    replyCount: 0,
    isDeleted: false,
    createdAt: DateTime.utc(2026, 8, 11, 10, 2),
  );
}

class _ScriptedLiveCommentsApi extends LiveCommentsApi {
  _ScriptedLiveCommentsApi(super.client);

  final Map<String, Completer<Either<Failure, List<LiveComment>>>>
  listResponses =
      <String, Completer<Either<Failure, List<LiveComment>>>>{};
  final List<
    ({
      String liveId,
      String comment,
      String? sessionId,
      String idempotencyKey,
    })
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
  Completer<Either<Failure, LiveComment>>? addResponse;
  Either<Failure, void> deleteResult = Either.right(null);

  @override
  Future<Either<Failure, List<LiveComment>>> listComments({
    required String liveId,
    int start = 0,
    int limit = 80,
  }) {
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
  Future<Either<Failure, void>> deleteComment({
    required String commentId,
  }) async {
    return deleteResult;
  }
}
