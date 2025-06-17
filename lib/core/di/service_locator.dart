import 'package:get_it/get_it.dart';

import '../utils/api_client.dart';

import '/features/auth/data/auth_remote_datasource.dart';
import '/features/auth/presentation/auth_provider.dart';

/***** WEBSITE ITEMS *******/
import '/features/website/domain/repo.dart';
import '/features/website/domain/usecases.dart';
import '/features/website/data/remote.dart';
import '/features/website/data/repo_impl.dart';
import '/features/website/prov.dart';

/*****  ITEMS *******/
import '/features/item/domain/repo.dart';
import '/features/item/domain/usecases.dart';
import '/features/item/data/remote.dart';
import '/features/item/data/repo_impl.dart';
import '/features/item/prov.dart';

/***** ITEMPRICE *******/
import '/features/itemPrice/data/remote.dart';
import '/features/itemPrice/data/repo_impl.dart';
import '/features/itemPrice/domain/repo.dart';
import '/features/itemPrice/domain/usecase.dart';
import '/features/itemPrice/prov.dart';

/***** SALESORDER *******/
import '/features/order/data/remote.dart';
import '/features/order/data/repo_impl.dart';
import '/features/order/domain/repo.dart';
import '/features/order/domain/usecases.dart';
import '/features/order/prov.dart';


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
  sl.registerLazySingleton(() => GetAllWebItemsUseCase(sl<WebsiteRepo>()));
  sl.registerLazySingleton(() => CreateWebItemUseCase(sl<WebsiteRepo>()));
  sl.registerLazySingleton(() => UpdateWebItemUseCase(sl<WebsiteRepo>()));
  // 4. Provider (State Management)
  sl.registerFactory(
    () =>
        WebsiteItemProv(getAllItems: sl(), createItem: sl(), updateItem: sl()),
  );

  // ITEMS Doctype

  // 1. Remote data source
  sl.registerLazySingleton(() => ItemRemoteDataSource(sl<APIClient>()));
  // 2. Repository
  sl.registerLazySingleton<ItemRepo>(
    () => ItemRepoImpl(sl<ItemRemoteDataSource>()),
  );
  // 3. Use Cases
  sl.registerLazySingleton(() => GetAllItemsUseCase(sl<ItemRepo>()));
  sl.registerLazySingleton(() => GetItemByNameUseCase(sl<ItemRepo>()));
  sl.registerLazySingleton(() => CreateItemUseCase(sl<ItemRepo>()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl<ItemRepo>()));
  // 4. Provider (State Management)
  sl.registerFactory(
    () => ItemProv(
      getAllItems: sl(),
      getItemByName: sl(),
      createItem: sl(),
      updateItem: sl(),
    ),
  );

  // ITEMPRICE Doctype

  // === Data ===
  sl.registerLazySingleton<ItemPriceRemoteDS>(
    () => ItemPriceRemoteDS(sl<APIClient>()),
  );
  // === Repository ===
  sl.registerLazySingleton<ItemPriceRepo>(
    () => ItemPriceRepoImpl(remote: sl()),
  );

  // === Domain ===
  sl.registerLazySingleton(() => GetAllItemPrices(sl()));
  sl.registerLazySingleton(() => CreateItemPrice(sl()));

  // === PROVIDER ===
  sl.registerFactory(() => ItemPriceProvider(getAll: sl(), create: sl()));

  // SALESORDER Doctype
  // === Dara ===
  sl.registerLazySingleton<SalesOrderRemoteDS>(
    () => SalesOrderRemoteDS(sl<APIClient>()),
  );
  // === Repository ===
  sl.registerLazySingleton<SalesOrderRepo>(
    () => SalesOrderRepoImpl(remote: sl()),
  );
  // === Domain ===
  sl.registerLazySingleton(() => GetAllSalesOrders(sl()));

  //  === PROVIDER ===
  sl.registerFactory(() => SalesOrderProvider(getAllSalesOrders: sl()));
}
