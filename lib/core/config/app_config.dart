class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'AOS_BASE_URL',
    // IMPORTANT: Keep this WITHOUT a trailing slash to avoid `//api/...` URLs.
    defaultValue: 'https://aos-staging.m.frappe.cloud',
  );

  /// Runtime-safe baseUrl (removes any trailing slash in case a value
  /// is provided with `/` via environment).
  static String get normalizedBaseUrl {
    final v = baseUrl.trim();
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }

  static const String googleWebClientId = String.fromEnvironment(
    'AOS_GOOGLE_WEB_CLIENT_ID',
    defaultValue: 'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com',
  );
}
