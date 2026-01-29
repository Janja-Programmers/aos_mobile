import 'dart:ui';

class DeviceLocaleInfo {
  const DeviceLocaleInfo({
    required this.languageCode,
    required this.countryCode,
    required this.timezone,
  });

  final String languageCode;
  final String? countryCode;
  final String timezone;
}

/// Detects basic device locale info.
///
/// Note: Flutter cannot reliably read the IANA timezone without a plugin.
/// We accept an injected timezone string from the app when available.
DeviceLocaleInfo detectDeviceLocale({String timezoneFallback = 'UTC'}) {
  final locale = PlatformDispatcher.instance.locale;
  return DeviceLocaleInfo(
    languageCode: locale.languageCode,
    countryCode: locale.countryCode,
    timezone: timezoneFallback,
  );
}
