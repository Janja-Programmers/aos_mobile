import 'package:flutter/widgets.dart';

class DeviceLocale {
  static String languageCode() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final code = locale.languageCode.trim().toLowerCase();
    return code;
  }

  static String? countryCode() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final code = locale.countryCode?.trim().toUpperCase();
    return (code == null || code.isEmpty) ? null : code;
  }
}
