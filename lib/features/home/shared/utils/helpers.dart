import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

String priceText(AOSAdListItem ad) {
  final type = ad.priceType.trim();
  if (type.toLowerCase() == 'free') return 'Free';
  if (type.toLowerCase() == 'contact for price') return 'Contact for price';
  if (ad.price == null) return '';

  final cur = ad.currency.trim();
  final p = ad.price!.toStringAsFixed(ad.price! % 1 == 0 ? 0 : 2);
  final unit = ad.priceUnit.trim();
  if (unit.isNotEmpty) return '$cur $p / $unit';
  return '$cur $p';
}

String toFullUrl(String fileUrl) {
  final u = fileUrl.trim();
  final url = '${AppConfig.normalizedBaseUrl}/$u';
  return url;
}
