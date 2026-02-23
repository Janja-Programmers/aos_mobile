import 'package:intl/intl.dart';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

String humanizePrice(num value) {
  final formatter = NumberFormat('#,##0.##');
  return formatter.format(value);
}

String priceText(AOSAdListItem ad) {
  final type = ad.priceType.trim().toLowerCase();

  if (type == 'free') return 'Free';
  if (type == 'contact for price') return 'Contact for price';

  final display = ad.priceDisplay.trim();
  if (display.isEmpty) return '';

  // Try to split currency + amount
  final parts = display.split(' ');
  if (parts.length < 2) return display;

  final currency = parts.first;
  final rawAmount = parts.sublist(1).join(' ');

  // Remove commas if already present
  final numeric = rawAmount.replaceAll(',', '');

  final parsed = num.tryParse(numeric);
  if (parsed == null) return display;

  final humanized = humanizePrice(parsed);

  return '$currency $humanized';
}

String formattedOriginalPrice(AOSAdListItem ad) {
  if (ad.price == null) return '';
  final cur = ad.currency.trim();
  return '$cur ${humanizePrice(ad.price!)}';
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
