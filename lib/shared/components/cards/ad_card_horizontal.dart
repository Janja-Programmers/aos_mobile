import 'package:africaonlinestores/shared/components/cards/widgets/ad_card_body.dart';
import 'package:africaonlinestores/shared/components/cards/widgets/ad_card_image.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

class AdHorizontalCard extends StatelessWidget {
  const AdHorizontalCard({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: colors.surface,
          border: BoxBorder.all(color: colors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: AdCardImage(ad: ad, height: 100),
            ),

            SizedBox(
              height: 110,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: AdCardBody(ad: ad),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
