import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/section_card.dart';

class AdHeaderInfoSection extends StatelessWidget {
  const AdHeaderInfoSection({
    super.key,
    required this.colorsPrimary,
    required this.locationName,
    required this.country,
    required this.title,
    this.currentPrice,
    required this.priceUnit,
  });

  final Color colorsPrimary;
  final String locationName;
  final String country;
  final String title;
  final String? currentPrice;
  final String priceUnit;

  String _locationText() {
    return [locationName, country].where((e) => e.trim().isNotEmpty).join(', ');
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
          Text(
            currentPrice.toString(),
            style: context.pStrong.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
