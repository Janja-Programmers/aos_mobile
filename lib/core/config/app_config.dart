class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'AOS_BASE_URL',
    defaultValue: 'https://aos-staging.duckdns.org',
  );

  static const String siteName = String.fromEnvironment(
    'AOS_SITENAME',
    defaultValue: 'aos-staging.duckdns.org',
  );

  static const String googleWebClientId = String.fromEnvironment(
    'AOS_GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '92816366774-skkbkd75qpkeh2fpj6lf9ut2icuh1uf3.apps.googleusercontent.com',
  );

  static const String mapBaseUrl = String.fromEnvironment(
    'AOS_MAP_BASE_URL',
    defaultValue: 'https://aos-maps-staging.duckdns.org',
  );

  static String get normalizedBaseUrl {
    final v = baseUrl.trim();
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }

  static String get normalizedMapBaseUrl {
    final v = mapBaseUrl.trim();
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }

  static String get mapStyleUrl {
    const override = String.fromEnvironment('AOS_MAP_STYLE_URL');
    if (override.trim().isNotEmpty) return override.trim();
    return '$normalizedMapBaseUrl/styles/aos/style.json';
  }
}
