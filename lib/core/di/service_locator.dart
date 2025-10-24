import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../db/db_helper.dart';
import '../utils/api_client.dart';

/***** Auth *******/
import '/screens/auth/auth_provider.dart';
import '/features/auth/data/auth_remote_datasource.dart';
import '/features/auth/data/auth_repository_impl.dart';
import '/features/auth/domain/auth_repository.dart';
import '/features/auth/domain/usecases/login.dart';
import '/features/auth/domain/usecases/register.dart';
import '/features/auth/domain/usecases/reset.dart';

/***** WEBSITE ITEMS *******/
import '/features/website/domain/repo.dart';
import '/features/website/domain/usecases.dart';
import '/features/website/data/remote.dart';
import '/features/website/data/repo_impl.dart';
import '/features/website/prov.dart';
import '/features/website/slider_prov.dart';
import '/features/reviews/remote.dart';

/***** PRODUCT *******/
import '/features/product/data/remote.dart';
import '/features/product/data/repo_impl.dart';
import '/features/product/domain/repo.dart';
import '/features/product/domain/usecase.dart';
import '/features/product/provider.dart';
import '/screens/customer/web-items/utils/vendor_utils.dart';

/***** SALESORDER *******/
import '/features/order/data/remote.dart';
import '/features/order/data/repo_impl.dart';
import '/features/order/domain/repo.dart';
import '/features/order/domain/usecases.dart';
import '/features/order/prov.dart';
import '/screens/customer/orders/provider.dart';

/***** SALESINVOICE *******/
import '/features/invoice/data/remote.dart';
import '/features/invoice/data/repo_impl.dart';
import '/features/invoice/domain/repo.dart';
import '/features/invoice/domain/usecases.dart';
import '/features/invoice/prov.dart';

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
import '/features/stock/providers/all.dart';
import '/features/stock/providers/create.dart';
import '/features/stock/providers/read.dart';
import '/features/stock/providers/delete.dart';

/***** CART *******/
import '/features/cart/domain/usecase.dart';
import '/features/cart/domain/repo.dart';
import '/features/cart/data/repo_impl.dart';
import '/features/cart/data/local.dart';
import '/features/cart/data/remote.dart';
import '/features/cart/provider.dart';

/***** ADDRESS ********/
import '/features/address/data/repo_impl.dart';
import '/features/address/data/remote.dart';
import '/features/address/domain/repo.dart';
import '/features/address/provider.dart';

/***** CHART ********/
import '/features/charts/data/remote.dart';
import '/features/charts/data/repo_impl.dart';
import '/features/charts/domain/repo.dart';
import '/features/charts/domain/usecase.dart';
import '/features/charts/presentation/provider.dart';

/***** WISHLIST ********/
import '/features/wishlist/data/local_data_source.dart';
import '/features/wishlist/data/repo_impl.dart';
import '/features/wishlist/domain/usecases.dart';
import '/features/wishlist/domain/wishlist_repo.dart';
import '/features/wishlist/provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // DATABASE Helper
  // Shared DB
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // API Client
  final apiClient = await APIClient.create();
  sl.registerSingleton<APIClient>(apiClient);
  sl.registerSingleton<Dio>(apiClient.client);

  // AUTH Feature
  // Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUser(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPassword(sl<AuthRepository>()));

  // Provider
  sl.registerSingleton<AuthProvider>(
    AuthProvider(
      loginUser: sl<LoginUser>(),
      registerUser: sl<RegisterUser>(),
      resetPass: sl<ResetPassword>(),
      apiClient: sl<APIClient>(),
    ),
  );

  // WEB Items

  // 1. Remote data source
  sl.registerLazySingleton(() => WebsiteRemoteDataSource(sl<APIClient>()));
  sl.registerLazySingleton(() => ReviewsRemote(sl<APIClient>()));

  // 2. Repository
  sl.registerLazySingleton<WebsiteRepo>(
    () => WebsiteRepoImpl(sl<WebsiteRemoteDataSource>()),
  );
  // 3. Use Cases
  sl.registerLazySingleton(() => GetAllWebItemsUseCase(sl<WebsiteRepo>()));
  sl.registerLazySingleton(() => GetSingleWebItemUseCase(sl<WebsiteRepo>()));
  // 4. Provider (State Management)
  sl.registerFactory(
    () => WebsiteItemProv(getAllItems: sl(), getSingleItem: sl()),
  );
  sl.registerFactory(() => SliderProv(sl<APIClient>()));

  // SALESORDER Doctype
  // === Data Layer ===
  sl.registerLazySingleton<SalesOrderRemoteDS>(
    () => SalesOrderRemoteDS(sl<APIClient>()),
  );
  sl.registerLazySingleton<SalesOrderPayloadRemoteDS>(
    () => SalesOrderPayloadRemoteDS(sl<APIClient>()),
  );

  // === Repository Layer ===
  sl.registerLazySingleton<SalesOrderRepo>(
    () => SalesOrderRepoImpl(
      remote: sl<SalesOrderRemoteDS>(),
      payloadRemote: sl<SalesOrderPayloadRemoteDS>(),
    ),
  );

  // === Domain Layer ===
  sl.registerLazySingleton(() => GetAllSalesOrders(sl()));
  sl.registerLazySingleton(() => GetSalesOrderById(sl()));
  sl.registerLazySingleton(() => DeliverSalesOrder(sl()));
  sl.registerLazySingleton(() => BillSalesOrder(sl()));
  sl.registerLazySingleton(() => PlaceOrderUseCase(sl()));

  // === Provider Layer ===
  sl.registerFactory(
    () => SalesOrderProvider(
      getAllSalesOrders: sl(),
      getById: sl(),
      deliver: sl(),
      bill: sl(),
      placeOrder: sl(),
    ),
  );
  sl.registerLazySingleton(() => CustomerOrderProvider(sl()));

  // SALESINVOICE Doctype
  // === Data Layer ===
  sl.registerLazySingleton<SalesInvoiceRemoteDS>(
    () => SalesInvoiceRemoteDS(sl<APIClient>()),
  );

  // === Repository Layer ===
  sl.registerLazySingleton<SalesInvoiceRepo>(
    () => SalesInvoiceRepoImpl(remote: sl<SalesInvoiceRemoteDS>()),
  );

  // === Domain Layer ===
  sl.registerLazySingleton(() => GetAllSalesInvoices(sl()));
  sl.registerLazySingleton(() => GetSalesInvoiceById(sl()));
  sl.registerLazySingleton(() => MarkSalesInvoiceAsPaid(sl()));

  // === Provider Layer ===
  sl.registerFactory(
    () => SalesInvoiceProvider(
      getAllSalesInvoices: sl(),
      getById: sl(),
      markPaid: sl(),
    ),
  );

  // DELIVERYNOTE Doctype
  // === Data ===
  sl.registerLazySingleton(() => DeliveryNoteRemoteDS(sl<APIClient>()));
  // === Repository ===
  sl.registerLazySingleton<DeliveryNoteRepo>(
    () => DeliveryNoteRepoImpl(remote: sl()),
  );
  // === Domain ===
  sl.registerLazySingleton(() => GetAllDeliveryNotes(sl()));
  sl.registerLazySingleton(() => GetDeliveryNoteById(sl()));
  // === Provider ===
  sl.registerFactory(
    () => DeliveryNoteProvider(getAllDeliveryNotes: sl(), getById: sl()),
  );

  // STOCKENTRY Doctype
  // === Data ===
  sl.registerLazySingleton(() => StockEntryRemoteDS(sl()));

  // === Repository ===
  sl.registerLazySingleton<StockEntryRepo>(
    () => StockEntryRepoImpl(sl<StockEntryRemoteDS>()),
  );

  // === Domain ===
  sl.registerLazySingleton(() => GetAllStockEntries(sl()));
  sl.registerLazySingleton(() => AddStockEntry(sl()));
  sl.registerLazySingleton(() => UpdateStockEntry(sl()));
  sl.registerLazySingleton(() => GetStockEntryById(sl()));
  sl.registerLazySingleton(() => DeleteStockEntry(sl()));

  // === Providers ===
  sl.registerFactory(() => StockEntryProvider(getAll: sl()));
  sl.registerFactory(() => StockEntryDetailProvider(getById: sl()));
  sl.registerFactory(
    () => CreateStockEntryProvider(add: sl(), update: sl(), getById: sl()),
  );
  sl.registerFactory(() => DeleteStockEntryProvider(delete: sl()));

  // CART Feature

  // ==== Data ===
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSource(sl()),
  );
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSource(sl()),
  );

  // === Repository ===
  sl.registerLazySingleton<CartRepo>(() => CartRepoImpl(sl(), sl()));
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
      placeOrder: sl(),
      authProvider: sl<AuthProvider>(),
    ),
  );

  // PRODUCTS Feature
  // === Data ===
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );
  // === Repository ===
  sl.registerLazySingleton<ProductRepo>(() => ProductRepoImpl(sl()));
  // === Domain ===
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => CreateProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => VendorUtils(sl<APIClient>()));

  // === Provider ===
  sl.registerFactory(() => ProductProvider(sl(), sl(), sl()));

  // ADDRESS Feature
  // ✅ Remote datasource
  sl.registerLazySingleton<AddressRemoteDatasource>(
    () => AddressRemoteDatasourceImpl(sl()),
  );

  // ✅ Repository
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remote: sl<AddressRemoteDatasource>()),
  );

  // ✅ Provider
  sl.registerLazySingleton<AddressProvider>(
    () => AddressProvider(repository: sl<AddressRepository>()),
  );

  // CHART Feature
  sl.registerLazySingleton(() => SalesChartRemoteDS(sl<APIClient>()));
  sl.registerLazySingleton<SalesChartRepo>(() => SalesChartRepoImpl(sl()));
  sl.registerLazySingleton(() => GetSalesChart(sl()));
  sl.registerFactory(() => SalesChartProvider(getChart: sl()));

  // WISHLIST Feature
  sl.registerLazySingleton(() => GetWishlist(sl()));
  sl.registerLazySingleton(() => AddToWishlist(sl()));
  sl.registerLazySingleton(() => RemoveFromWishlist(sl()));
  sl.registerLazySingleton<WishlistRepo>(() => WishlistRepoImpl(sl()));
  sl.registerLazySingleton<WishlistLocalDataSource>(
    () => WishlistLocalDataSourceImpl(),
  );
  sl.registerLazySingleton(
    () => WishlistProvider(
      getWishlist: sl(),
      addToWishlist: sl(),
      removeFromWishlist: sl(),
    ),
  );
}
