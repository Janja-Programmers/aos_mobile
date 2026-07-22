import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';
import '../../helpers/auth_api_harness.dart';

void main() {
  test('registration posts the implemented frontend fields', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{'ok': true, 'message': 'Registered.'},
      }),
    );
    final harness = await buildAuthApiHarness(adapter);

    await harness.api.register(
      email: 'user@example.invalid',
      password: 'fake-password',
      fullName: 'Test User',
      country: 'KE',
      language: 'en',
      currency: 'KES',
    );

    expect(adapter.singleRequest.path, ApiEndpoints.registerEndpoint);
    expect(adapter.singleRequest.method, 'POST');
    expect(adapter.singleRequest.data, <String, dynamic>{
      'email': 'user@example.invalid',
      'password': 'fake-password',
      'full_name': 'Test User',
      'country': 'KE',
      'language': 'en',
      'currency': 'KES',
    });
  });

  test('email verification posts email and OTP only', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{'ok': true, 'message': 'Verified.'},
      }),
    );
    final harness = await buildAuthApiHarness(adapter);

    await harness.api.verifyOtp(email: 'user@example.invalid', otp: '123456');

    expect(adapter.singleRequest.path, ApiEndpoints.verifyOtpEndpoint);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'email': 'user@example.invalid',
      'otp': '123456',
    });
  });

  test('forgot-password verification posts the current OTP contract', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': true,
          'data': <String, dynamic>{'reset_token': 'fake-reset-token'},
        },
      }),
    );
    final harness = await buildAuthApiHarness(adapter);

    await harness.api.forgotPasswordVerifyOtp(
      email: 'user@example.invalid',
      otp: '123456',
    );

    expect(
      adapter.singleRequest.path,
      ApiEndpoints.forgotPasswordVerifyOtpEndpoint,
    );
    expect(adapter.singleRequest.data, <String, dynamic>{
      'email': 'user@example.invalid',
      'otp': '123456',
    });
  });

  test('password reset keeps token and confirmation fields explicit', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{'ok': true, 'message': 'Updated.'},
      }),
    );
    final harness = await buildAuthApiHarness(adapter);

    await harness.api.forgotPasswordReset(
      email: 'user@example.invalid',
      resetToken: 'fake-reset-token',
      newPassword: 'fake-new-password',
      confirmPassword: 'fake-new-password',
    );

    expect(
      adapter.singleRequest.path,
      ApiEndpoints.forgotPasswordResetEndpoint,
    );
    expect(adapter.singleRequest.data, <String, dynamic>{
      'email': 'user@example.invalid',
      'reset_token': 'fake-reset-token',
      'new_password': 'fake-new-password',
      'confirm_password': 'fake-new-password',
    });
  });
}
