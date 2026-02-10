import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/home/components/ad_details/section_card.dart';

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

  String _priceText() {
    final display = priceDisplay.trim();
    if (display.isNotEmpty) return display;

    return [
      currency,
      (price ?? 0).toString(),
      if (priceUnit.trim().isNotEmpty) priceUnit,
    ].where((e) => e.trim().isNotEmpty).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: colorsPrimary, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _locationText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _priceText(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorsPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
