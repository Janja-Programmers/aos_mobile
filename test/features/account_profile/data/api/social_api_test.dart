import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';
import '../../helpers/account_profile_api_harness.dart';
import '../../helpers/account_profile_fixture.dart';

void main() {
  test('relationship status uses backend GET contract', () async {
    final Map<String, dynamic> fixture = await loadAccountProfileMessageFixture(
      'public_profile_friend.json',
    );
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) =>
          jsonResponse(<String, dynamic>{'message': fixture}),
    );
    final AccountProfileApiHarness harness =
        await buildAccountProfileApiHarness(adapter);
    addTearDown(harness.container.dispose);

    final result = await harness.socialApi.getRelationshipStatus(
      targetUser: ' friend@example.invalid ',
    );

    expect(result.isRight, isTrue);
    expect(adapter.singleRequest.method, 'GET');
    expect(
      adapter.singleRequest.path,
      ApiEndpoints.getRelationshipStatusEndpoint,
    );
    expect(adapter.singleRequest.queryParameters, <String, dynamic>{
      'target_user': 'friend@example.invalid',
    });
    expect(result.rightOrNull?.actionLabel, 'Friends');
  });

  test('toggle follow posts exact target_user body', () async {
    final Map<String, dynamic> fixture = await loadAccountProfileMessageFixture(
      'follow_success.json',
    );
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) =>
          jsonResponse(<String, dynamic>{'message': fixture}),
    );
    final AccountProfileApiHarness harness =
        await buildAccountProfileApiHarness(adapter);
    addTearDown(harness.container.dispose);

    final result = await harness.socialApi.toggleFollow(
      targetUser: ' public@example.invalid ',
    );

    expect(result.isRight, isTrue);
    expect(adapter.singleRequest.method, 'POST');
    expect(adapter.singleRequest.path, ApiEndpoints.toggleFollowEndpoint);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'target_user': 'public@example.invalid',
    });
  });

  test(
    'connection lists send only supported paging and search fields',
    () async {
      final Map<String, dynamic> fixture =
          await loadAccountProfileMessageFixture('connections_page.json');
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) =>
            jsonResponse(<String, dynamic>{'message': fixture}),
      );
      final AccountProfileApiHarness harness =
          await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);

      await harness.socialApi.getFollowers(
        limit: 20,
        start: 40,
        targetUser: 'unsupported-target@example.invalid',
        query: ' test ',
      );

      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, ApiEndpoints.getFollowsEndpoint);
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'limit': 20,
        'start': 40,
        'search': 'test',
      });
      expect(
        adapter.singleRequest.queryParameters.containsKey('target_user'),
        isFalse,
      );
      expect(
        adapter.singleRequest.queryParameters.containsKey('user'),
        isFalse,
      );
      expect(adapter.singleRequest.queryParameters.containsKey('q'), isFalse);
    },
  );

  test('empty target is rejected before network access', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{}),
    );
    final AccountProfileApiHarness harness =
        await buildAccountProfileApiHarness(adapter);
    addTearDown(harness.container.dispose);

    final result = await harness.socialApi.toggleFollow(targetUser: '  ');

    expect(result.isLeft, isTrue);
    expect(adapter.requests, isEmpty);
  });
}
