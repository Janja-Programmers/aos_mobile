import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/utils/file_url.dart';
import 'package:africaonlinestores/features/home/utils/helpers.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class AdCard extends StatelessWidget {
  const AdCard({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  static const double _cardHeight = 250;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final subtitle = [
      if (ad.locationName.isNotEmpty) ad.locationName,
      if (ad.country.isNotEmpty) ad.country,
    ].join(', ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _cardHeight,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 IMAGE TAKES FLEX SPACE
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ad.coverImage.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.08),
                          child: const Icon(Icons.image_outlined),
                        )
                      : Image.network(
                          buildFileUrl(ad.coverImage) ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image_outlined),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              /// 🔥 TEXT SECTION
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.pStrong,
                    ),

                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.p,
                      ),
                    ],

                    const Spacer(),

                    Text(
                      priceText(ad),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
