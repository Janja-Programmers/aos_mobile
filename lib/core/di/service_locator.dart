import 'package:get_it/get_it.dart';

import '../utils/api_client.dart';

import '/features/auth/data/auth_remote_datasource.dart';
import '/features/auth/presentation/auth_provider.dart';

/***** WEBSITE ITEMS *******/
import '/features/website/domain/repo.dart';
import '/features/website/domain/usecases.dart';
import '/features/website/data/remote.dart';
import '/features/website/data/repo_impl.dart';
import '/features/website/presentation/prov.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // APIClient
  sl.registerLazySingleton(() => APIClient());
  sl.registerLazySingleton(() => sl<APIClient>().client);

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerFactory(() => AuthProvider(sl()));

  // WEB Items

  // 1. Remote data source
  sl.registerLazySingleton(() => WebsiteRemoteDataSource(sl<APIClient>()));
  // 2. Repository
  sl.registerLazySingleton<WebsiteRepo>(
    () => WebsiteRepoImpl(sl<WebsiteRemoteDataSource>()),
  );
  // 3. Use Cases
  sl.registerLazySingleton(() => GetAllItemsUseCase(sl<WebsiteRepo>()));
  // 4. Provider (State Management)
  sl.registerFactory(() => WebsiteItemProv(getAllItems: sl()));
}
