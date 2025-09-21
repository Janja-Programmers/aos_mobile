import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '/core/constants/const.dart';

class APIClient {
  late final Dio _dio;
  late final PersistCookieJar _cookieJar;

  APIClient._internal(Dio? dio) : _dio = dio ?? Dio();

  static Future<APIClient> create({Dio? dio}) async {
    final client = APIClient._internal(dio);
    await client._setup();
    return client;
  }

  Future<void> _setup() async {
    // Prepare cookie storage
    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/.cookies/'),
    );

    _dio.options
      ..baseUrl = ApiRoutes.baseUrl
      ..connectTimeout = const Duration(seconds: 25)
      ..receiveTimeout = const Duration(seconds: 25);

    final interceptors = <Interceptor>[
      CookieManager(_cookieJar),
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
        onResponse: (response, handler) => handler.next(response),
        onError: (error, handler) => handler.next(error),
      ),
    ];

    _dio.interceptors.addAll(interceptors);
  }

  Dio get client => _dio;

  Future<void> clearCookies() async => _cookieJar.deleteAll();
}
