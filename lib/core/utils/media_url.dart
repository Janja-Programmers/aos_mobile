import 'package:africaonlinestores/core/config/app_config.dart';

String? normalizeMediaUrl(String? value) {
  final text = value?.trim();

  if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }

  if (text.startsWith('http://') ||
      text.startsWith('https://') ||
      text.startsWith('data:') ||
      text.startsWith('file://')) {
    return text;
  }

  if (text.startsWith('//')) {
    return 'https:$text';
  }

  if (text.startsWith('/')) {
    return '${AppConfig.normalizedBaseUrl}$text';
  }

  return '${AppConfig.normalizedBaseUrl}/$text';
}
