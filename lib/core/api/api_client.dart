import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

/// API client for Frappe backend.
///
/// Uses a CookieJar + CookieManager so session cookies (sid) are handled
/// automatically.
class ApiClient {
  ApiClient({required String baseUrl})
    : baseUri = Uri.parse(_normalizeBaseUrl(baseUrl)),
      cookieJar = CookieJar(),
      dio = Dio(
        BaseOptions(
          baseUrl: _normalizeBaseUrl(baseUrl),
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // Cookie management
    dio.interceptors.add(CookieManager(cookieJar));

    // Locale/currency context headers (set by LocaleController).
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

    // Debug logging only (avoid leaking info + reduce noise in release).
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

  Map<String, String> _contextHeaders = const {};

  String? _sid;
  String? get sid => _sid;

  /// Sets sid into the CookieJar (preferred) and also keeps it in memory.
  Future<void> setSid(String sid) async {
    _sid = sid;
    final cookie = Cookie('sid', sid)
      ..path = '/'
      ..httpOnly = true;

    await cookieJar.saveFromResponse(baseUri, [cookie]);
  }

  /// Clears sid from memory and CookieJar.
  Future<void> clearSid() async {
    _sid = null;
    await cookieJar.delete(baseUri);
  }

  /// Sets locale/country/currency context headers that will be attached to
  /// all outgoing requests.
  ///
  /// These headers are used by the backend to tailor responses.
  void setContext({String? countryCode, String? languageCode, String? currencyCode}) {
    final next = <String, String>{};
    if (countryCode != null && countryCode.isNotEmpty) {
      next['X-AOS-Country'] = countryCode;
    }
    if (languageCode != null && languageCode.isNotEmpty) {
      next['X-AOS-Language'] = languageCode;
    }
    if (currencyCode != null && currencyCode.isNotEmpty) {
      next['X-AOS-Currency'] = currencyCode;
    }
    _contextHeaders = next;
  }
}

String _normalizeBaseUrl(String baseUrl) {
  final v = baseUrl.trim();
  return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
}
