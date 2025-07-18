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
    // 🔐 Private internal constructor
    final client = APIClient._internal(dio);

    // Get a directory to store cookies
    final dir = await getApplicationDocumentsDirectory();
    client._cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/.cookies/'),
      ignoreExpires: false,
    );

    client._dio.options
      ..baseUrl = ApiRoutes.baseUrl
      ..connectTimeout = const Duration(seconds: 25)
      ..receiveTimeout = const Duration(seconds: 25);

    client._dio.interceptors.addAll([
      CookieManager(client._cookieJar),
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) => handler.next(e),
      ),
    ]);

    return client;
  }

  Dio get client => _dio;

  Future<void> clearCookies() async => _cookieJar.deleteAll();
}
