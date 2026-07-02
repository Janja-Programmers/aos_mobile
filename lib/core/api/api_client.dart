import 'dart:async';

import 'package:africaonlinestores/features/auth/shared/utils/enums.dart';
import 'package:africaonlinestores/features/preferences/service/preference_api_sync.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Optional abstraction if you want external preference injection
abstract class PreferenceReader {
  String get countryCode;
  String get currencyCode;
  String get languageCode;
}

class ApiClient {
  // ----------------------------
  // CORE
  // ----------------------------
  final Dio dio;
  final CookieJar cookieJar;
  final Uri baseUri;

  final PreferenceReader? preferences;

  // ----------------------------
  // SESSION EVENTS
  // ----------------------------
  final _sessionExpiredCtrl = StreamController<void>.broadcast();
  Stream<void> get sessionExpiredStream => _sessionExpiredCtrl.stream;

  // ----------------------------
  // CONTEXT HEADERS
  // ----------------------------
  final Map<String, String> _contextHeaders = {};

  // ----------------------------
  // CONSTRUCTOR
  // ----------------------------
  ApiClient({required String baseUrl, required Ref ref, this.preferences})
    : baseUri = Uri.parse(_normalizeBaseUrl(baseUrl)),
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
    // preference sync (side-effect)
    PreferenceApiSync(this, ref).init();

    // cookies
    dio.interceptors.add(CookieManager(cookieJar));

    // headers injection
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

    // session handling
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          if (error.response?.statusCode == 401) {
            _sessionExpiredCtrl.add(null);
          }
          handler.next(error);
        },
      ),
    );
  }

  // ----------------------------
  // SID
  // ----------------------------
  Future<void> setSid(String sid) async {
    final cookie = Cookie('sid', sid)
      ..path = '/'
      ..httpOnly = true;

    await cookieJar.saveFromResponse(baseUri, [cookie]);
  }

  Future<void> clearSid() async {
    await cookieJar.deleteAll();
  }

  // ----------------------------
  // CONTEXT
  // ----------------------------
  void setContext({
    String? countryCode,
    String? languageCode,
    String? currencyCode,
  }) {
    _contextHeaders.clear();

    if (countryCode?.isNotEmpty ?? false) {
      _contextHeaders['X-AOS-Country'] = countryCode!;
    }
    if (languageCode?.isNotEmpty ?? false) {
      _contextHeaders['X-AOS-Language'] = languageCode!;
    }
    if (currencyCode?.isNotEmpty ?? false) {
      _contextHeaders['X-AOS-Currency'] = currencyCode!;
    }
  }

  // ----------------------------
  // MARKET CONTEXT HELPERS
  // ----------------------------
  Map<String, dynamic>? _injectMarketContext(Map<String, dynamic>? input) {
    if (preferences == null) return input;

    final country = preferences!.countryCode;
    final currency = preferences!.currencyCode;

    if (country.isEmpty || currency.isEmpty) return input;

    return {...?input, 'country': country, 'currency': currency};
  }

  Map<String, dynamic>? _injectCountryOnly(Map<String, dynamic>? input) {
    if (preferences == null) return input;

    final country = preferences!.countryCode;
    if (country.isEmpty) return input;

    return {...?input, 'country': country};
  }

  // ----------------------------
  // GET
  // ----------------------------
  Future<Response<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool marketContext = false,
    CountryPlacement countryPlacement = CountryPlacement.query,
    Options? options,
  }) {
    final qp =
        (marketContext &&
            (countryPlacement == CountryPlacement.query ||
                countryPlacement == CountryPlacement.both))
        ? _injectMarketContext(queryParameters)
        : queryParameters;

    return dio.get<Map<String, dynamic>>(
      path,
      queryParameters: qp,
      options: options,
    );
  }

  // ----------------------------
  // POST
  // ----------------------------
  Future<Response<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool marketContext = false,
    CountryPlacement countryPlacement = CountryPlacement.query,
    Options? options,
  }) {
    final qp =
        (marketContext &&
            (countryPlacement == CountryPlacement.query ||
                countryPlacement == CountryPlacement.both))
        ? _injectMarketContext(queryParameters)
        : queryParameters;

    final body =
        (marketContext &&
            (countryPlacement == CountryPlacement.body ||
                countryPlacement == CountryPlacement.both))
        ? _injectCountryOnly(data)
        : data;

    return dio.post<Map<String, dynamic>>(
      path,
      data: body,
      queryParameters: qp,
      options: options,
    );
  }

  // ----------------------------
  // DISPOSE
  // ----------------------------
  void dispose() {
    unawaited(_sessionExpiredCtrl.close());
  }
}

// ----------------------------
// UTIL
// ----------------------------
String _normalizeBaseUrl(String baseUrl) {
  final v = baseUrl.trim();
  return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
}
