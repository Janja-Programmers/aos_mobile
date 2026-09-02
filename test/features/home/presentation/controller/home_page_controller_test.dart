import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/catalog/domain/categories_repository.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/provider_container.dart';
import '../../../../helpers/test_preferences.dart';
import '../../../../test_config/test_environment.dart';

void main() {
  test(
    'homepage requests backend categories using canonical ids only',
    () async {
      final preferences = await setUpTestPreferences();
      final onboardingStorage = OnboardingStorage(preferences);
      const categories = <CategoryNode>[
        CategoryNode(id: 'CAT-A', name: 'Alpha display', isGroup: true),
        CategoryNode(id: 'CAT-B', name: 'Beta display', isGroup: true),
        CategoryNode(id: 'CAT-C', name: 'Gamma display', isGroup: true),
        CategoryNode(id: 'CAT-D', name: 'Delta display', isGroup: true),
      ];
      late _RecordingAdsApi api;

      final clientProvider = Provider<ApiClient>((Ref ref) {
        final client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
        ref.onDispose(client.dispose);
        return client;
      });

      final container = createTestContainer(
        overrides: <Override>[
          onboardingStorageProvider.overrideWithValue(onboardingStorage),
          categoriesRepositoryProvider.overrideWithValue(
            const _FakeCategoriesRepository(categories),
          ),
          adsApiProvider.overrideWith((Ref ref) {
            // ignore: join_return_with_assignment
            api = _RecordingAdsApi(ref.read(clientProvider));
            return api;
          }),
        ],
      );

      container.read(adsApiProvider);
      final subscription = container.listen(
        homePageControllerProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await pumpEventQueue();

      final state = container.read(homePageControllerProvider).value;
      expect(state, isNotNull);
      expect(
        state!.selectedCategories
            .map((CategoryNode category) => category.id)
            .toSet(),
        <String>{'CAT-A', 'CAT-B', 'CAT-C', 'CAT-D'},
      );

      final requestedCategoryIds = api.categoryIds.whereType<String>().toList();
      expect(requestedCategoryIds.toSet(), <String>{
        'CAT-A',
        'CAT-B',
        'CAT-C',
        'CAT-D',
      });
      expect(requestedCategoryIds, hasLength(4));
      expect(requestedCategoryIds, isNot(contains('Alpha display')));
    },
  );
}

class _FakeCategoriesRepository implements CategoriesRepository {
  const _FakeCategoriesRepository(this.categories);

  final List<CategoryNode> categories;

  @override
  Future<Either<Failure, List<CategoryNode>>> getCategories() async {
    return Either<Failure, List<CategoryNode>>.right(categories);
  }
}

class _RecordingAdsApi extends AdsApi {
  _RecordingAdsApi(super.client);

  final List<String?> categoryIds = <String?>[];

  @override
  Future<Either<Failure, Map<String, dynamic>>> listAds({
    String? locationId,
    String? categoryId,
    String? sellerId,
    String? q,
    String? sort,
    String? priceType,
    String? promotionType,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    int limit = 20,
    int offset = 0,
  }) async {
    categoryIds.add(categoryId);
    return Either<Failure, Map<String, dynamic>>.right(<String, dynamic>{
      'data': <String, dynamic>{'items': <Map<String, dynamic>>[]},
    });
  }
}
