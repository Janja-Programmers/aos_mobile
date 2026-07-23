import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/recording_http_client_adapter.dart';
import '../../helpers/account_profile_api_harness.dart';

void main() {
  test('delete account posts exact confirmation and trimmed reason', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': true,
          'message': 'Account deleted.',
          'data': <String, dynamic>{'restore_window_days': 30},
        },
      }),
    );
    final AccountProfileApiHarness harness =
        await buildAccountProfileApiHarness(adapter);
    addTearDown(harness.container.dispose);

    final result = await harness.lifecycleApi.deleteAccount(
      confirmation: 'DELETE',
      reason: ' Test reason ',
    );

    expect(result.isRight, isTrue);
    expect(adapter.singleRequest.method, 'POST');
    expect(adapter.singleRequest.path, ApiEndpoints.deleteAccount);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'confirmation': 'DELETE',
      'reason': 'Test reason',
    });
  });

  test('restore request uses generic email-only contract', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': true,
          'message':
              'If a restorable account exists, a restore code has been sent.',
        },
      }),
    );
    final AccountProfileApiHarness harness =
        await buildAccountProfileApiHarness(adapter);
    addTearDown(harness.container.dispose);

    await harness.lifecycleApi.requestRestore(email: ' owner@example.invalid ');

    expect(adapter.singleRequest.path, ApiEndpoints.requestRestoreAccount);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'email': 'owner@example.invalid',
    });
  });

  test('restore account posts email and OTP only', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': true,
          'message': 'Account restored. Please login.',
        },
      }),
    );
    final AccountProfileApiHarness harness =
        await buildAccountProfileApiHarness(adapter);
    addTearDown(harness.container.dispose);

    await harness.lifecycleApi.restoreAccount(
      email: ' owner@example.invalid ',
      otp: ' 123456 ',
    );

    expect(adapter.singleRequest.path, ApiEndpoints.restoreAccount);
    expect(adapter.singleRequest.data, <String, dynamic>{
      'email': 'owner@example.invalid',
      'otp': '123456',
    });
  });
}
