import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';
import '../../helpers/account_profile_api_harness.dart';
import '../../helpers/account_profile_fixture.dart';

void main() {
  group('AccountsApi getProfile', () {
    test('uses GET without target_user for the current profile', () async {
      final Map<String, dynamic> fixture =
          await loadAccountProfileMessageFixture('own_profile.json');
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) =>
            jsonResponse(<String, dynamic>{'message': fixture}),
      );
      final AccountProfileApiHarness harness =
          await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);

      final result = await harness.accountsApi.getProfile();

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, ApiEndpoints.getProfileEndpoint);
      expect(adapter.singleRequest.queryParameters, isEmpty);
    });

    test('sends only target_user for a public profile', () async {
      final Map<String, dynamic> fixture =
          await loadAccountProfileMessageFixture('public_profile_follow.json');
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) =>
            jsonResponse(<String, dynamic>{'message': fixture}),
      );
      final AccountProfileApiHarness harness =
          await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);

      await harness.accountsApi.getProfile(
        targetUser: ' public@example.invalid ',
      );

      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.queryParameters, <String, dynamic>{
        'target_user': 'public@example.invalid',
      });
      expect(
        adapter.singleRequest.queryParameters.containsKey('user'),
        isFalse,
      );
    });

    test(
      'maps PROFILE_UNAVAILABLE without producing fallback profile data',
      () async {
        final Map<String, dynamic> fixture =
            await loadAccountProfileMessageFixture('profile_unavailable.json');
        final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
          (RequestOptions options) => jsonResponse(<String, dynamic>{
            'message': fixture,
          }, statusCode: 403),
        );
        final AccountProfileApiHarness harness =
            await buildAccountProfileApiHarness(adapter);
        addTearDown(harness.container.dispose);

        final result = await harness.accountsApi.getProfile(
          targetUser: 'hidden@example.invalid',
        );

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull?.error, 'PROFILE_UNAVAILABLE');
        expect(result.leftOrNull?.type, FailureType.forbidden);
      },
    );
  });

  group('AccountsApi updateProfile', () {
    test('posts exact backend-supported fields', () async {
      final Map<String, dynamic> fixture =
          await loadAccountProfileMessageFixture('profile_update_success.json');
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) =>
            jsonResponse(<String, dynamic>{'message': fixture}),
      );
      final AccountProfileApiHarness harness =
          await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);

      final result = await harness.accountsApi.updateProfile(
        fullName: ' Updated   Owner ',
        bio: ' Updated bio. ',
        userImageMedia: ' MEDIA-TEST-PROFILE-002 ',
      );

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.method, 'POST');
      expect(adapter.singleRequest.path, ApiEndpoints.updateProfileEndpoint);
      expect(adapter.singleRequest.data, <String, dynamic>{
        'full_name': 'Updated Owner',
        'bio': 'Updated bio.',
        'avatar_media_id': 'MEDIA-TEST-PROFILE-002',
      });
    });

    test('uses remove_avatar for avatar clearing', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'message': 'Profile updated.',
            'data': <String, dynamic>{'user': 'owner@example.invalid'},
          },
        }),
      );
      final AccountProfileApiHarness harness =
          await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);

      await harness.accountsApi.updateProfile(userImage: '');

      expect(adapter.singleRequest.data, <String, dynamic>{
        'remove_avatar': true,
      });
    });

    test('maps timeout deterministically', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter((
        RequestOptions options,
      ) {
        throw DioException.connectionTimeout(
          timeout: const Duration(seconds: 30),
          requestOptions: options,
        );
      });
      final AccountProfileApiHarness harness =
          await buildAccountProfileApiHarness(adapter);
      addTearDown(harness.container.dispose);

      final result = await harness.accountsApi.updateProfile(bio: 'Safe bio');

      expect(result.leftOrNull?.type, FailureType.timeout);
      expect(adapter.requests, hasLength(1));
    });
  });
}
