import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/rating_display.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';

class AdHeaderInfoSection extends StatelessWidget {
  const AdHeaderInfoSection({
    super.key,
    required this.colorsPrimary,
    required this.locationName,
    required this.country,
    required this.title,
    this.currentPrice,
    required this.priceUnit,
    this.priceType,
    required this.rating,
    required this.reviewCount,
  });

  final Color colorsPrimary;
  final String locationName;
  final String country;
  final String title;
  final String? currentPrice;
  final String? priceType;
  final String priceUnit;
  final double rating;
  final int reviewCount;

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

          RatingDisplay(rating: rating, reviewCount: reviewCount),

          const SizedBox(height: 10),

          /// Price
          Row(
            children: [
              Text(
                currentPrice.toString(),
                style: context.pStrong.copyWith(fontSize: 20),
              ),

              const SizedBox(width: 8),

              _buildNegotiableBadge(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiableBadge(BuildContext context) {
    final colors = context.appColors;

    if ((priceType ?? '').toLowerCase() != 'negotiable') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: colors.surface,
        border: Border.all(color: colors.border, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.handshake_outlined, size: 12, color: colors.textPrimary),

            const SizedBox(width: 4),

            Text(
              "Negotiable",
              style: context.pStrong.copyWith(
                fontSize: 12,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
