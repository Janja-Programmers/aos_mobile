import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/widgets.dart';

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
      ad.isOfferActive &&
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

String homeSectionTitle(BuildContext context, String key) {
  final l10n = context.l10n;

  switch (key) {
    case 'flash_sales':
      return l10n.home_flash_sales;
    case 'services':
      return l10n.home_services_near_you;
    case 'new_products':
      return l10n.home_new_products;
    case 'electronic_deal':
      return l10n.home_electronic_deals;
    case 'deal':
      return l10n.home_deals;
    case 'furniture':
      return l10n.home_furniture;
    case 'electronics':
      return l10n.home_electronics;
    case 'fashion':
      return l10n.home_fashion;
    case 'kids':
      return l10n.home_babies_kids;
    case 'beauty':
      return l10n.home_beauty;
    default:
      return '';
  }
}
