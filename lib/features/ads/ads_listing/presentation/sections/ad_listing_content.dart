import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';

class AdListingContentView extends StatelessWidget {
  const AdListingContentView({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onMarkSold,
  });

  final List<AOSAdListItem> items;
  final void Function(AOSAdListItem ad) onEdit;
  final void Function(AOSAdListItem ad) onMarkSold;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) =>
          _MyAdTile(ad: items[i], onEdit: onEdit, onMarkSold: onMarkSold),
    );
  }
}

class _MyAdTile extends StatelessWidget {
  const _MyAdTile({
    required this.ad,
    required this.onEdit,
    required this.onMarkSold,
  });

  final AOSAdListItem ad;
  final void Function(AOSAdListItem ad) onEdit;
  final void Function(AOSAdListItem ad) onMarkSold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    final imageUrl = buildFileUrl(ad.primaryImage);
    final price = resolveAdPrice(ad);

    final location = [
      if (ad.locationName.isNotEmpty) ad.locationName,
      if (ad.country.isNotEmpty) ad.country,
    ].join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              /// IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Container(
                          color: scheme.surface,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_outlined,
                            color: scheme.primary,
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.category_outlined,
                            color: scheme.primary,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              /// INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title.isEmpty ? 'Untitled draft' : ad.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.pStrong,
                    ),

                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: context.pMuted.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    /// PRICE
                    if (price.show) ...[
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Text(price.current ?? '', style: context.pStrong),

                          if (price.original != null &&
                              price.original!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              price.original!,
                              style: context.p.copyWith(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ACTIONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onEdit(ad),
                  child: Text(
                    'Edit',
                    style: context.p.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FilledButton(
                  onPressed: () => onMarkSold(ad),
                  child: Text(
                    'Mark as sold',
                    style: context.p.copyWith(
                      color: colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
