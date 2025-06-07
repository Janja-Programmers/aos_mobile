import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:ownashop/core/constants/const.dart';

class APIClient {
  final Dio _dio;
  final Logger _logger;

  APIClient({Dio? dio}) : _dio = dio ?? Dio(), _logger = Logger() {
    // ✅ Set base URL
    _dio.options.baseUrl = BASE_URL;

    // Logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('Body: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('✅ RESPONSE[${response.statusCode}]: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _logger.e('❌ ERROR[${e.response?.statusCode}]: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;
}
