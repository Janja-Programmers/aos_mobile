import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/maps/navigation/maps_routes.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:flutter/material.dart';

class SellerLocationSection extends StatelessWidget {
  const SellerLocationSection({
    super.key,
    required this.sellerId,
    required this.location,
  });

  final String sellerId;
  final AOSSellerLocation location;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final address = location.subtitle ?? location.title;

    return SectionCard(
      title: 'Shop location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 126,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withValues(alpha: .08),
                  colors.elevated,
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 54,
                    color: colors.primary.withValues(alpha: .65),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 36,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.p,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () {
                  MapsNavigation.toExplorer<void>(context, sellerId: sellerId);
                },
                icon: Icon(
                  Icons.directions_outlined,
                  size: 18,
                  color: colors.white,
                ),
                label: Text(
                  'Directions',
                  style: AppTextStylesX(context).button,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
