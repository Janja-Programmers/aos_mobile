import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/section_card.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class AdHeaderInfoSection extends StatelessWidget {
  const AdHeaderInfoSection({
    super.key,
    required this.colorsPrimary,
    required this.locationName,
    required this.country,
    required this.title,
    required this.priceDisplay,
    required this.currency,
    required this.price,
    required this.priceUnit,
  });

  final Color colorsPrimary;

  final String locationName;
  final String country;
  final String title;

  final String priceDisplay;
  final String currency;
  final num? price;
  final String priceUnit;

  String _locationText() {
    return [locationName, country].where((e) => e.trim().isNotEmpty).join(', ');
  }

  /// Safely humanizes backend display price if needed
  String _humanizedDisplayPrice(String display) {
    final parts = display.split(' ');
    if (parts.length < 2) return display;

    final currencyPart = parts.first;
    final rawAmount = parts.sublist(1).join(' ');

    final numeric = rawAmount.replaceAll(',', '');
    final parsed = num.tryParse(numeric);

    if (parsed == null) return display;

    final humanized = humanizePrice(parsed);
    return '$currencyPart $humanized';
  }

  String _priceText() {
    final display = priceDisplay.trim();

    /// 1️⃣ Prefer backend display price
    if (display.isNotEmpty) {
      return _humanizedDisplayPrice(display);
    }

    /// 2️⃣ Fallback to raw price
    if (price == null) return '';

    final formatted = humanizePrice(price!);
    final cur = currency.trim();
    final unit = priceUnit.trim();

    if (unit.isNotEmpty) {
      return '$cur $formatted / $unit';
    }

    return '$cur $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Location Row
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: colorsPrimary, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(_locationText(), style: context.p)),
            ],
          ),

          const SizedBox(height: 6),

          /// Title
          Text(title, style: context.pStrong),

          const SizedBox(height: 10),

          /// Price
          Text(_priceText(), style: context.pStrong.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}
