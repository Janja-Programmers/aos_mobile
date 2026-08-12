import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../helpers/live_api_harness.dart';
import '../helpers/live_fixtures.dart';

void main() {
  test('host invitation uses only the opaque LiveKit identity', () async {
    final adapter = RecordingHttpClientAdapter((RequestOptions options) {
      return jsonResponse(
        successEnvelope(<String, dynamic>{
          'cohost': _cohostJson(requestType: 'host_invite'),
        }),
      );
    });
    final harness = await buildLiveApiHarness(adapter);

    final result = await harness.cohostApi.inviteCohost(
      liveId: testLiveId,
      livekitIdentity: 'aos:participant:opaque-viewer',
    );

    expect(result.isRight, isTrue);
    expect(adapter.singleRequest.path, ApiEndpoints.inviteLiveCohost);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'live_id': testLiveId,
      'livekit_identity': 'aos:participant:opaque-viewer',
    });
    expect(
      (adapter.singleRequest.data! as Map<String, dynamic>)
          .containsKey('session_id'),
      isFalse,
    );
  });

  test('response sends canonical action and normalized reason', () async {
    final adapter = RecordingHttpClientAdapter((RequestOptions options) {
      return jsonResponse(
        successEnvelope(<String, dynamic>{
          'cohost': _cohostJson(status: 'rejected'),
        }),
      );
    });
    final harness = await buildLiveApiHarness(adapter);

    await harness.cohostApi.respondCohost(
      cohostId: 'COHOST-001',
      accept: false,
      reason: '  Not now  ',
    );

    expect(adapter.singleRequest.path, ApiEndpoints.respondLiveCohost);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'cohost_id': 'COHOST-001',
      'action': 'reject',
      'reason': 'Not now',
    });
  });

  test('co-host token response retains server role and credentials', () async {
    final adapter = RecordingHttpClientAdapter((RequestOptions options) {
      return jsonResponse(
        successEnvelope(<String, dynamic>{
          'session': <String, dynamic>{
            'live_id': testLiveId,
            'room_name': 'room-$testLiveId',
            'token': 'private-cohost-token',
            'ws_url': 'wss://livekit.example.invalid',
            'role': 'cohost',
            'identity': 'aos:participant:opaque-viewer',
            'session_id': testViewerSessionId,
          },
        }),
      );
    });
    final harness = await buildLiveApiHarness(adapter);

    final result = await harness.cohostApi.getCohostToken(
      cohostId: 'COHOST-001',
      sessionId: testViewerSessionId,
    );

    expect(result.rightOrNull?.role, AOSLiveRole.cohost);
    expect(result.rightOrNull?.token, 'private-cohost-token');
    expect(adapter.singleRequest.path, ApiEndpoints.getLiveCohostToken);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'cohost_id': 'COHOST-001',
      'session_id': testViewerSessionId,
    });
  });
}

Map<String, dynamic> _cohostJson({
  String requestType = 'viewer_request',
  String status = 'pending',
}) {
  return <String, dynamic>{
    'cohost_id': 'COHOST-001',
    'live_id': testLiveId,
    'user': 'ACC-2026-00002',
    'session_id': testViewerSessionId,
    'livekit_identity': 'aos:participant:opaque-viewer',
    'request_type': requestType,
    'status': status,
    'is_active': false,
    'display_name': 'Test Viewer',
    'expires_at': '2026-08-11T10:05:00Z',
  };
}
