import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '/core/db/db_helper.dart';
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

/*****  DELIVERYNOTE *******/
import '/features/d_note/data/remote.dart';
import '/features/d_note/data/repo_impl.dart';
import '/features/d_note/domain/repo.dart';
import '/features/d_note/domain/usecases.dart';
import '/features/d_note/prov.dart';

/***** STOCK */
import '/features/stock/data/remote.dart';
import '/features/stock/data/repo_impl.dart';
import '/features/stock/domain/repo.dart';
import '/features/stock/domain/usecases.dart';
import '/features/stock/prov.dart';

/***** CART *******/
import '/features/cart/domain/usecase.dart';
import '/features/cart/domain/repo.dart';
import '/features/cart/data/repo_impl.dart';
import '/features/cart/data/local.dart';
import '/features/cart/provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // DATABASE Helper
  // Shared DB
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // API Client
  final apiClient = await APIClient.create();
  sl.registerSingleton<APIClient>(apiClient);
  sl.registerSingleton<Dio>(apiClient.client);

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

  // DELIVERYNOTE Doctype
  // === Data ===
  sl.registerLazySingleton(() => DeliveryNoteRemoteDS(sl<APIClient>()));
  // === Repository ===
  sl.registerLazySingleton<DeliveryNoteRepo>(
    () => DeliveryNoteRepoImpl(remote: sl()),
  );
  // === Domain ===
  sl.registerLazySingleton(() => GetAllDeliveryNotes(sl()));
  // === PROVIDER ===
  sl.registerFactory(() => DeliveryNoteProvider(getAllDeliveryNotes: sl()));

  // STOCKENTRY Doctype
  // === Data ===
  sl.registerLazySingleton(() => StockEntryRemoteDS(sl()));
  // === Repository ===
  sl.registerLazySingleton<StockEntryRepo>(
    () => StockEntryRepoImpl(remote: sl()),
  );
  // === Domain ===
  sl.registerLazySingleton(() => GetAllStockEntries(sl()));
  // === Provider ===
  sl.registerFactory(() => StockEntryProvider(getAll: sl()));

  // CART Feature
  // ==== Data ===
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSource(sl()),
  );
  // === Repository ===
  sl.registerLazySingleton<CartRepo>(() => CartRepoImpl(sl()));
  // === Domain ===
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantityUseCase(sl()));
  // === Provider ===
  sl.registerLazySingleton(
    () => CartProvider(
      getCartItems: sl(),
      addToCart: sl(),
      removeFromCart: sl(),
      clearCart: sl(),
      updateQty: sl(),
    ),
  );
}
