import 'package:africaonlinestores/core/config/app_config.dart';

String? buildCategoryIconUrl(String? icon) {
  if (icon == null || icon.trim().isEmpty) return null;

  final v = icon.trim();
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  if (v.startsWith('/')) return '${AppConfig.normalizedBaseUrl}$v';
  return '${AppConfig.normalizedBaseUrl}/$v';
}
