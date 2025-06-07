import 'package:get_it/get_it.dart';

import '../utils/api_client.dart';
import '/features/auth/data/auth_remote_datasource.dart';
import '/features/auth/presentation/auth_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => APIClient());
  sl.registerLazySingleton(() => sl<APIClient>().client);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Providers
  sl.registerFactory(() => AuthProvider(sl()));
}
