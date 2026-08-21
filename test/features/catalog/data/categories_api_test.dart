import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/features/catalog/data/categories_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/recording_http_client_adapter.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/test_preferences.dart';
import '../../../test_config/test_environment.dart';

void main() {
  test('uses the exact public endpoint and parses the active tree', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': true,
          'message': 'Categories fetched.',
          'data': <Object?>[
            _category(
              id: 'Electronics',
              group: true,
              children: <Object?>[
                _category(id: 'Mobile Phones', parentId: 'Electronics'),
              ],
            ),
          ],
        },
      }),
    );
    final CategoriesApi api = await _api(adapter);

    final result = await api.getCategories();

    expect(result.isRight, isTrue);
    expect(adapter.singleRequest.path, ApiEndpoints.getCategoriesEndpoint);
    expect(adapter.singleRequest.queryParameters, isEmpty);
    expect(result.rightOrNull!.single.id, 'Electronics');
    expect(result.rightOrNull!.single.children.single.id, 'Mobile Phones');
  });

  test('accepts an empty active catalog', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': true,
          'message': 'Categories fetched.',
          'data': <Object?>[],
        },
      }),
    );
    final CategoriesApi api = await _api(adapter);

    final result = await api.getCategories();

    expect(result.isRight, isTrue);
    expect(result.rightOrNull, isEmpty);
  });

  test('maps an invalid tree to a parse failure instead of throwing', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': true,
          'message': 'Categories fetched.',
          'data': <Object?>[_category(id: 'Leaf', parentId: 'Missing')],
        },
      }),
    );
    final CategoriesApi api = await _api(adapter);

    final result = await api.getCategories();

    expect(result.isLeft, isTrue);
    expect(result.leftOrNull!.type, FailureType.parse);
  });

  test('preserves the backend error identifier', () async {
    final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter(
      (RequestOptions options) => jsonResponse(<String, dynamic>{
        'message': <String, dynamic>{
          'ok': false,
          'message': 'Failed to fetch categories.',
          'error': 'CATALOG_DATA_ERROR',
          'data': <String, dynamic>{},
        },
      }),
    );
    final CategoriesApi api = await _api(adapter);

    final result = await api.getCategories();

    expect(result.isLeft, isTrue);
    expect(result.leftOrNull!.error, 'CATALOG_DATA_ERROR');
  });
}

Map<String, dynamic> _category({
  required String id,
  bool group = false,
  String? parentId,
  List<Object?> children = const <Object?>[],
}) {
  return <String, dynamic>{
    'id': id,
    'name': id,
    'icon': '',
    'icon_media': null,
    'icon_media_id': null,
    'parent_id': parentId,
    'sort_order': 0,
    'is_group': group ? 1 : 0,
    'children': children,
  };
}

Future<CategoriesApi> _api(RecordingHttpClientAdapter adapter) async {
  final preferences = await setUpTestPreferences();
  final ProviderContainer container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(
        OnboardingStorage(preferences),
      ),
    ],
  );
  final provider = Provider<ApiClient>((Ref ref) {
    final ApiClient client = ApiClient(
      baseUrl: TestEnvironment.apiBaseUrl,
      ref: ref,
    );
    client.dio.httpClientAdapter = adapter;
    ref.onDispose(client.dispose);
    return client;
  });
  return CategoriesApi(container.read(provider));
}
