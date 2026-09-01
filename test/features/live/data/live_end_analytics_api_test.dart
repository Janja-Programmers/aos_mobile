import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../helpers/live_api_harness.dart';
import '../helpers/live_fixtures.dart';

void main() {
  test('end Live preserves canonical final analytics snapshot', () async {
    final ended =
        liveJson(
            status: 'ended',
            isActive: false,
            viewerCount: 0,
            reactionCount: 91,
            isHost: true,
            canJoin: false,
            canWatch: false,
            canComment: false,
            canReact: false,
          )
          ..['peak_viewers'] = 37
          ..['unique_viewers'] = 52
          ..['duration_seconds'] = 814;

    final adapter = RecordingHttpClientAdapter((RequestOptions options) {
      return jsonResponse(successEnvelope(<String, dynamic>{'live': ended}));
    });
    final harness = await buildLiveApiHarness(adapter);

    final result = await harness.liveApi.endLive(liveId: testLiveId);
    final live = result.rightOrNull;

    expect(live, isNotNull);
    expect(live?.id, testLiveId);
    expect(live?.peakViewers, 37);
    expect(live?.uniqueViewers, 52);
    expect(live?.reactionCount, 91);
    expect(live?.durationSeconds, 814);
    expect(adapter.singleRequest.path, ApiEndpoints.endLiveEndpoint);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'live_id': testLiveId,
    });
  });
}
