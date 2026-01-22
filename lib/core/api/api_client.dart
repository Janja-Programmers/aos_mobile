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
}

String _normalizeBaseUrl(String baseUrl) {
  final v = baseUrl.trim();
  return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
}
