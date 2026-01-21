class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'AOS_BASE_URL',
    defaultValue: 'https://aos-staging.m.frappe.cloud/',
  );
}
