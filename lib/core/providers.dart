import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/session_storage.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return const SessionStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(baseUrl: AppConfig.normalizedBaseUrl, ref: ref);

  ref.onDispose(client.dispose);
  return client;
});
