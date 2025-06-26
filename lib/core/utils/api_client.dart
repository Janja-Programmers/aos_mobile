import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:ownashop/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import '/core/constants/const.dart';

class APIClient {
  late final Dio _dio;
  late final PersistCookieJar _cookieJar;
  final Logger _logger;

  // 🔐 Private internal constructor
  APIClient._internal(Dio? dio) : _dio = dio ?? Dio(), _logger = Logger();

  /// ✅ Factory constructor you call
  static Future<APIClient> create({Dio? dio}) async {
    final client = APIClient._internal(dio);

    // Get a directory to store cookies
    final dir = await getApplicationDocumentsDirectory();
    client._cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/.cookies/'),
      ignoreExpires: false,
    );

    client._dio.options
      ..baseUrl = BASE_URL
      ..connectTimeout = const Duration(seconds: 25)
      ..receiveTimeout = const Duration(seconds: 25);

    client._dio.interceptors.addAll([
      CookieManager(client._cookieJar),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          client._logger.i('➡️ ${options.method} ${options.uri}');
          print(
            "🌐 API CLIENT sending request to ${options.uri} with body: ${options.data}",
          );
          if (options.data != null) client._logger.i('Body: ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          client._logger.i(
            '✅ ${response.statusCode} ← ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          appLogger.e('❌ Server error: ${e.response?.data}');
          client._logger.e(
            '❌ ${e.response?.statusCode} ← ${e.requestOptions.uri}',
          );
          client._logger.e(e);
          return handler.next(e);
        },
      ),
    ]);

    return client;
  }

  Dio get client => _dio;

  /// 🧹 Call this on logout
  Future<void> clearCookies() async => _cookieJar.deleteAll();
}
