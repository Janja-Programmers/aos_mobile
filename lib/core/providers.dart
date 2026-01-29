import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/session_storage.dart';
import 'package:africaonlinestores/core/config/app_config.dart';

import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/catalog/data/categories_api.dart';
import 'package:africaonlinestores/features/localization/data/localization_api.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return const SessionStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppConfig.normalizedBaseUrl);
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final accountsApiProvider = Provider<AccountsApi>((ref) {
  return AccountsApi(ref.watch(apiClientProvider));
});

final categoriesApiProvider = Provider<CategoriesApi>((ref) {
  return CategoriesApi(ref.watch(apiClientProvider));
});

final localizationApiProvider = Provider<LocalizationApi>((ref) {
  return LocalizationApi(ref.watch(apiClientProvider));
});
