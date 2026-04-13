import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/auth/shared/utils/enums.dart';

class ApiClient {
  final Ref _ref;

  final _sessionExpiredCtrl = StreamController<void>.broadcast();
  Stream<void> get sessionExpiredStream => _sessionExpiredCtrl.stream;

  ApiClient({required String baseUrl, required Ref ref})
    : _ref = ref,
      baseUri = Uri.parse(_normalizeBaseUrl(baseUrl)),
      cookieJar = CookieJar(),
      dio = Dio(
        BaseOptions(
          baseUrl: _normalizeBaseUrl(baseUrl),
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // 🔥 HARDcode SID here

    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_sid != null) {
            options.headers['Cookie'] = 'sid=$_sid';
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_contextHeaders.isNotEmpty) {
            options.headers.addAll(_contextHeaders);
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final status = error.response?.statusCode;

          if (status == 401) {
            _sessionExpiredCtrl.add(null);
          }

          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
  }

  final Dio dio;
  final CookieJar cookieJar;
  final Uri baseUri;

  final Map<String, String> _contextHeaders = {};

  String? _sid;
  String? get sid => _sid;

  Future<void> setSid(String sid) async {
    _sid = sid;

    final cookie = Cookie('sid', sid)
      ..path = '/'
      ..httpOnly = true;

    await cookieJar.saveFromResponse(baseUri, [cookie]);
  }

  Future<void> clearSid() async {
    _sid = null;
    await cookieJar.delete(baseUri);
  }

  void setContext({
    String? countryCode,
    String? languageCode,
    String? currencyCode,
  }) {
    _contextHeaders.clear();

    if (countryCode?.isNotEmpty == true) {
      _contextHeaders['X-AOS-Country'] = countryCode!;
    }
    if (languageCode?.isNotEmpty == true) {
      _contextHeaders['X-AOS-Language'] = languageCode!;
    }
    if (currencyCode?.isNotEmpty == true) {
      _contextHeaders['X-AOS-Currency'] = currencyCode!;
    }
  }

  /// Synchronous resolution (cheap)

  String? _resolveCountryCode() {
    final prefs = _ref.read(userPreferenceControllerProvider);
    final code = prefs.countryCode;
    return (code.isEmpty) ? null : code;
  }

  String? _resolveCurrencyCode() {
    final prefs = _ref.read(userPreferenceControllerProvider);
    final code = prefs.currencyCode;
    return (code.isEmpty) ? null : code;
  }

  Map<String, dynamic>? _injectmarketContextIntoQuery(
    Map<String, dynamic>? queryParameters,
    bool marketContext,
  ) {
    if (!marketContext) return queryParameters;
    final country = _resolveCountryCode();
    final currency = _resolveCurrencyCode();
    if (country == null || currency == null) return queryParameters;
    return {...?queryParameters, 'country': country, 'currency': currency};
  }

  Map<String, dynamic>? _injectCountryIntoBody(
    Map<String, dynamic>? body,
    bool marketContext,
  ) {
    if (!marketContext) return body;
    final country = _resolveCountryCode();
    if (country == null) return body;
    return {...?body, 'country': country};
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool marketContext = false,
    CountryPlacement countryPlacement = CountryPlacement.query,
    Options? options,
  }) {
    final qp =
        (countryPlacement == CountryPlacement.query ||
            countryPlacement == CountryPlacement.both)
        ? _injectmarketContextIntoQuery(queryParameters, marketContext)
        : queryParameters;

    return dio.get<T>(path, queryParameters: qp, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool marketContext = false,
    CountryPlacement countryPlacement = CountryPlacement.query,
    Options? options,
  }) {
    final qp =
        (countryPlacement == CountryPlacement.query ||
            countryPlacement == CountryPlacement.both)
        ? _injectmarketContextIntoQuery(queryParameters, marketContext)
        : queryParameters;

    final body =
        (countryPlacement == CountryPlacement.body ||
            countryPlacement == CountryPlacement.both)
        ? _injectCountryIntoBody(data, marketContext)
        : data;

    return dio.post<T>(path, data: body, queryParameters: qp, options: options);
  }
}

String _normalizeBaseUrl(String baseUrl) {
  final v = baseUrl.trim();
  return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
}
