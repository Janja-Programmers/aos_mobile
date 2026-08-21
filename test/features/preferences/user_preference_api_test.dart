import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/features/preferences/data/user_preference_api.dart';
import 'package:africaonlinestores/features/preferences/models/user_preference_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/recording_http_client_adapter.dart';
import '../../helpers/provider_container.dart';
import '../../helpers/test_preferences.dart';
import '../../test_config/test_environment.dart';

void main() {
  for (final testCase in <({
    UserPreferenceField field,
    String wireName,
    String canonicalId,
  })>[
    (
      field: UserPreferenceField.language,
      wireName: 'language',
      canonicalId: 'sw',
    ),
    (
      field: UserPreferenceField.country,
      wireName: 'country',
      canonicalId: 'Uganda',
    ),
    (
      field: UserPreferenceField.currency,
      wireName: 'currency',
      canonicalId: 'UGX',
    ),
  ]) {
    test(
      '${testCase.wireName} update uses RPC v2 and sends only its field',
      () async {
        final adapter = RecordingHttpClientAdapter(
          (_) => jsonResponse(<String, dynamic>{
            'data': <String, dynamic>{
              'ok': true,
              'message': 'Preference updated successfully.',
              'data': _preferenceFixture(
                field: testCase.field,
                canonicalId: testCase.canonicalId,
              ),
            },
          }),
        );
        final harness = await _buildHarness(adapter);

        final result = await harness.api.updateMyPreference(
          field: testCase.field,
          canonicalId: ' ${testCase.canonicalId} ',
        );

        expect(result.isRight, isTrue);
        expect(
          harness.adapter.singleRequest.path,
          '/api/v2/method/aos.api.v1.accounts.update_my_preference',
        );
        expect(
          harness.adapter.singleRequest.data,
          <String, dynamic>{testCase.wireName: testCase.canonicalId},
        );
        expect(
          (harness.adapter.singleRequest.data as Map<String, dynamic>)
              .containsKey('cmd'),
          isFalse,
        );
      },
    );
  }

  test('preserves the backend stable error from an RPC v2 response', () async {
    final adapter = RecordingHttpClientAdapter(
      (_) => jsonResponse(<String, dynamic>{
        'data': <String, dynamic>{
          'ok': false,
          'message': 'Country cannot be changed for this account.',
          'error': 'COUNTRY_LOCKED',
          'data': <String, dynamic>{},
        },
      }),
    );
    final harness = await _buildHarness(adapter);

    final result = await harness.api.updateMyPreference(
      field: UserPreferenceField.country,
      canonicalId: 'Uganda',
    );

    expect(result.isLeft, isTrue);
    expect(result.leftOrNull?.error, 'COUNTRY_LOCKED');
    expect(
      result.leftOrNull?.message,
      'Country cannot be changed for this account.',
    );
  });

  test('rejects an empty canonical ID without making a request', () async {
    final adapter = RecordingHttpClientAdapter(
      (_) => jsonResponse(<String, dynamic>{}),
    );
    final harness = await _buildHarness(adapter);

    final result = await harness.api.updateMyPreference(
      field: UserPreferenceField.language,
      canonicalId: '   ',
    );

    expect(result.isLeft, isTrue);
    expect(harness.adapter.requests, isEmpty);
  });
}

Map<String, dynamic> _preferenceFixture({
  required UserPreferenceField field,
  required String canonicalId,
}) {
  final values = <UserPreferenceField, String>{
    UserPreferenceField.country: 'Kenya',
    UserPreferenceField.currency: 'KES',
    UserPreferenceField.language: 'en',
  };
  values[field] = canonicalId;

  return <String, dynamic>{
    'country': <String, dynamic>{
      'id': values[UserPreferenceField.country],
      'name': values[UserPreferenceField.country],
      'code': field == UserPreferenceField.country ? 'UG' : 'KE',
    },
    'currency': <String, dynamic>{
      'id': values[UserPreferenceField.currency],
      'name': values[UserPreferenceField.currency],
      'code': values[UserPreferenceField.currency],
    },
    'language': <String, dynamic>{
      'id': values[UserPreferenceField.language],
      'name': values[UserPreferenceField.language],
      'code': values[UserPreferenceField.language],
    },
    'location': null,
    'is_country_locked': false,
  };
}

class _UserPreferenceApiHarness {
  const _UserPreferenceApiHarness({
    required this.api,
    required this.adapter,
  });

  final UserPreferenceApi api;
  final RecordingHttpClientAdapter adapter;
}

Future<_UserPreferenceApiHarness> _buildHarness(
  RecordingHttpClientAdapter adapter,
) async {
  final preferences = await setUpTestPreferences();
  final onboardingStorage = OnboardingStorage(preferences);

  final container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
    ],
  );
  final clientProvider = Provider<ApiClient>((ref) {
    final client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
    client.dio.httpClientAdapter = adapter;
    ref.onDispose(client.dispose);
    return client;
  });
  final client = container.read(clientProvider);

  return _UserPreferenceApiHarness(
    api: UserPreferenceApi(client),
    adapter: adapter,
  );
}
