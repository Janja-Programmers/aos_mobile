import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

class PriceDisplay {
  final bool show;
  final String? current;
  final String? original;

  const PriceDisplay({required this.show, this.current, this.original});
}

PriceDisplay buildPriceDisplay(AOSAdListItem ad) {
  final type = ad.priceType.trim().toLowerCase();

  // Free / Contact
  if (type == 'free' || type == 'contact for price') {
    return const PriceDisplay(show: false);
  }

  final current = ad.currentPrice;
  final original = ad.originalPrice;

  if (current == null || current.isEmpty) {
    return const PriceDisplay(show: false);
  }

  // Offer active
  if (ad.hasActiveOffer && original != null && original.isNotEmpty) {
    return PriceDisplay(show: true, current: current, original: original);
  }

  // Normal price
  return PriceDisplay(show: true, current: current);
}

String humanizeCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
  }
  return value.toString();
}

String toFullUrl(String fileUrl) {
  final u = fileUrl.trim();
  final url = '${AppConfig.normalizedBaseUrl}/$u';
  return url;
}
