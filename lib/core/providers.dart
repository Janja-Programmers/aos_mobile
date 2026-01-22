import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aos_mobile/core/api/api_client.dart';
import 'package:aos_mobile/core/api/session_storage.dart';
import 'package:aos_mobile/core/config/app_config.dart';
import 'package:aos_mobile/features/auth/data/auth_api.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return const SessionStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppConfig.normalizedBaseUrl);
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});
