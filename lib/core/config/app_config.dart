class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'AOS_BASE_URL',
    // IMPORTANT: Keep this WITHOUT a trailing slash to avoid `//api/...` URLs.
    // defaultValue: 'https://aos-staging.m.frappe.cloud',
    defaultValue: 'https://aos-staging.duckdns.org',
  );

  static const String siteName = String.fromEnvironment(
    'AOS_SITENAME',
    defaultValue: 'aos-staging.duckdns.org',
  );

  static const String googleWebClientId = String.fromEnvironment(
    'AOS_GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '779793412118-8n4ml1k5rgeic3bifvg9e57nntdiqdhb.apps.googleusercontent.com',
  );

  static String get normalizedBaseUrl {
    final v = baseUrl.trim();
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }

  static String get mapStyleUrl {
    const override = String.fromEnvironment('AOS_MAP_STYLE_URL');
    if (override.trim().isNotEmpty) return override.trim();
    return '$normalizedBaseUrl/maps/styles/aos/style.json';
  }
}
