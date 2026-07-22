import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';
import '../../helpers/auth_api_harness.dart';

void main() {
  group('AuthApi login', () {
    test(
      'posts the exact mobile request to the current login endpoint',
      () async {
        final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
          (RequestOptions options) => jsonResponse(<String, dynamic>{
            'message': <String, dynamic>{
              'ok': true,
              'data': <String, dynamic>{
                'session': <String, dynamic>{'sid': 'test-session-id'},
                'user': <String, dynamic>{'email': 'user@example.invalid'},
              },
            },
          }),
        );
        final harness = await buildAuthApiHarness(adapter);

        final result = await harness.api.login(
          identifier: 'user@example.invalid',
          password: 'fake-password',
        );

        expect(result.isRight, isTrue);
        expect(adapter.singleRequest.method, 'POST');
        expect(adapter.singleRequest.path, ApiEndpoints.loginEndpoint);
        expect(adapter.singleRequest.data, <String, dynamic>{
          'identifier': 'user@example.invalid',
          'password': 'fake-password',
          'client_type': 'mobile',
        });
        expect(
          adapter.singleRequest.headers[Headers.contentTypeHeader],
          'application/json',
        );
        expect(
          adapter.singleRequest.headers[Headers.acceptHeader],
          'application/json',
        );
      },
    );

    test('maps INVALID_CREDENTIALS from the error key', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': false,
            'error': 'INVALID_CREDENTIALS',
            'message': 'Account-specific detail must not be shown.',
          },
        }, statusCode: 401),
      );
      final harness = await buildAuthApiHarness(adapter);

      final result = await harness.api.login(
        identifier: 'user@example.invalid',
        password: 'fake-password',
      );
      final Failure? failure = result.leftOrNull;

      expect(failure?.error, 'INVALID_CREDENTIALS');
      expect(failure?.message, 'Invalid email, phone, or password.');
      expect(failure?.message, isNot(contains('Account-specific')));
    });

    test('maps timeout without contacting another service', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter((
        RequestOptions options,
      ) {
        throw DioException.connectionTimeout(
          timeout: const Duration(seconds: 60),
          requestOptions: options,
        );
      });
      final harness = await buildAuthApiHarness(adapter);

      final result = await harness.api.login(
        identifier: 'user@example.invalid',
        password: 'fake-password',
      );

      expect(result.leftOrNull?.type, FailureType.timeout);
      expect(adapter.requests, hasLength(1));
    });

    test('maps cancellation into a non-authenticated failure', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter((
        RequestOptions options,
      ) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
        );
      });
      final harness = await buildAuthApiHarness(adapter);

      final result = await harness.api.login(
        identifier: 'user@example.invalid',
        password: 'fake-password',
      );

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull?.message, 'Request cancelled.');
    });
  });

  group('AuthApi social login', () {
    test('Google exchange includes mobile client identification', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{'ok': true, 'data': <String, dynamic>{}},
        }),
      );
      final harness = await buildAuthApiHarness(adapter);

      await harness.api.googleLogin(
        idToken: 'fake-google-id-token',
        country: 'KE',
        language: 'en',
        currency: 'KES',
      );

      expect(adapter.singleRequest.path, ApiEndpoints.googleLoginEndpoint);
      expect(adapter.singleRequest.data, containsPair('client_type', 'mobile'));
      expect(
        adapter.singleRequest.data,
        containsPair('id_token', 'fake-google-id-token'),
      );
    });

    test('Apple exchange includes mobile client identification', () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{'ok': true, 'data': <String, dynamic>{}},
        }),
      );
      final harness = await buildAuthApiHarness(adapter);

      await harness.api.appleLogin(
        idToken: 'fake-apple-id-token',
        country: 'KE',
        language: 'en',
        currency: 'KES',
      );

      expect(adapter.singleRequest.path, ApiEndpoints.appleLoginEndpoint);
      expect(adapter.singleRequest.data, containsPair('client_type', 'mobile'));
      expect(
        adapter.singleRequest.data,
        containsPair('id_token', 'fake-apple-id-token'),
      );
    });
  });

  test(
    'me uses GET and does not send a SID in the response contract',
    () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
        (RequestOptions options) => jsonResponse(<String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{
              'user': <String, dynamic>{'email': 'user@example.invalid'},
              'preferences': <String, dynamic>{},
              'roles': <String>[],
              'seller': null,
            },
          },
        }),
      );
      final harness = await buildAuthApiHarness(adapter);

      final result = await harness.api.me();

      expect(result.isRight, isTrue);
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, ApiEndpoints.meEndpoint);
      final Map<String, dynamic> data =
          result.rightOrNull?['data'] as Map<String, dynamic>;
      expect(data.containsKey('sid'), isFalse);
    },
  );
}
