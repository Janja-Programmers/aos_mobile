import 'package:africaonlinestores/core/config/app_config.dart';

String? buildFileUrl(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  final v = path.trim();
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  if (v.startsWith('/')) return '${AppConfig.normalizedBaseUrl}$v';
  return '${AppConfig.normalizedBaseUrl}/$v';
}
