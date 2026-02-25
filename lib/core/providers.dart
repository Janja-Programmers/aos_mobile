import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/session_storage.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/localization/localization_controller.dart';
import 'package:africaonlinestores/core/localization/localization_state.dart';
import 'package:africaonlinestores/core/preferences/data/user_preference_api.dart';

import 'package:africaonlinestores/core/preferences/user_preference_controller.dart';
import 'package:africaonlinestores/core/preferences/user_preference_state.dart';

import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/catalog/data/categories_api.dart';
import 'package:africaonlinestores/features/localization/data/localization_api.dart';
import 'package:africaonlinestores/features/home/data/market_context_controller.dart';
import 'package:africaonlinestores/features/home/domain/market_place.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_controller.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_state.dart';
import 'package:africaonlinestores/features/home/wishlist/controller/wishlist_controller.dart';
import 'package:africaonlinestores/features/home/wishlist/controller/wishlist_state.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return const SessionStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppConfig.normalizedBaseUrl, ref: ref);
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final userPreferenceControllerProvider =
    AsyncNotifierProvider<UserPreferenceController, UserPreferenceState?>(
      UserPreferenceController.new,
    );

final userPreferenceApiProvider = Provider<UserPreferenceApi>((ref) {
  return UserPreferenceApi(ref.watch(apiClientProvider));
});

final localizationControllerProvider =
    AsyncNotifierProvider<LocalizationController, LocalizationState>(
      LocalizationController.new,
    );

final accountsApiProvider = Provider<AccountsApi>((ref) {
  return AccountsApi(ref.watch(apiClientProvider));
});

final categoriesApiProvider = Provider<CategoriesApi>((ref) {
  return CategoriesApi(ref.watch(apiClientProvider));
});

final localizationApiProvider = Provider<LocalizationApi>((ref) {
  return LocalizationApi(ref.watch(apiClientProvider));
});

final adsApiProvider = Provider<AdsApi>((ref) {
  return AdsApi(ref.watch(apiClientProvider));
});

final marketContextProvider =
    AsyncNotifierProvider<MarketContextController, MarketContext>(
      MarketContextController.new,
    );

final homePageControllerProvider =
    AsyncNotifierProvider<HomePageController, HomePageState>(
      HomePageController.new,
    );

final wishlistControllerProvider =
    AsyncNotifierProvider<WishlistController, WishlistState>(
      WishlistController.new,
    );
