import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

class AdPriceView {
  const AdPriceView({required this.show, this.current, this.original});

  final bool show;
  final String? current;
  final String? original;
}

AdPriceView resolveAdPrice(AOSAdListItem ad) {
  final hasPrice =
      ad.currentPrice != null && ad.currentPrice!.trim().isNotEmpty;

  if (!hasPrice) {
    return const AdPriceView(show: false);
  }

  final hasOffer =
      ad.isOfferActive == true &&
      ad.originalPrice != null &&
      ad.originalPrice!.trim().isNotEmpty;

  return AdPriceView(
    show: true,
    current: ad.currentPrice,
    original: hasOffer ? ad.originalPrice : null,
  );
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
