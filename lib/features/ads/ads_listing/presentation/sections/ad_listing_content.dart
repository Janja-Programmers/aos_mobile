import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';
import 'package:africaonlinestores/features/ads/ads_listing/utils/ad_lissting_actions.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';

class AdListingContentView extends StatelessWidget {
  const AdListingContentView({
    super.key,
    required this.items,
    required this.tab,
    required this.onEdit,
    required this.onMarkSold,
    required this.onDelete,
  });

  final List<AOSAdListItem> items;
  final AdTab tab;

  final void Function(AOSAdListItem ad) onEdit;
  final void Function(AOSAdListItem ad) onMarkSold;
  final void Function(AOSAdListItem ad) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _MyAdTile(
        ad: items[i],
        tab: tab,
        onEdit: onEdit,
        onMarkSold: onMarkSold,
        onDelete: onDelete,
      ),
    );
  }
}

class _MyAdTile extends StatelessWidget {
  const _MyAdTile({
    required this.ad,
    required this.tab,
    required this.onEdit,
    required this.onMarkSold,
    required this.onDelete,
  });

  final AOSAdListItem ad;
  final AdTab tab;

  final void Function(AOSAdListItem ad) onEdit;
  final void Function(AOSAdListItem ad) onMarkSold;
  final void Function(AOSAdListItem ad) onDelete;

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

    final actions = AdListingActions.forTab(
      tab: tab,
      ad: ad,
      onEdit: onEdit,
      onMarkSold: onMarkSold,
      onDelete: () => onDelete(ad), // wire later
      onContactSupport: () {},
    );

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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Container(
                          color: scheme.surface,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_outlined),
                        )
                      : Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(width: 12),

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
                      Text(location, style: context.pMuted),
                    ],

                    if (price.show) ...[
                      const SizedBox(height: 4),
                      Text(price.current ?? '', style: context.pStrong),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// FINAL ACTIONS
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: actions.map((a) {
              switch (a.type) {
                case AdActionType.primary:
                  return FilledButton(
                    onPressed: a.onPressed,
                    child: Text(
                      a.label,
                      style: context.p.copyWith(color: colors.white),
                    ),
                  );

                case AdActionType.secondary:
                  return OutlinedButton(
                    onPressed: a.onPressed,
                    child: Text(a.label),
                  );

                case AdActionType.destructive:
                  return OutlinedButton(
                    onPressed: a.onPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: Text(a.label),
                  );

                case AdActionType.disabled:
                  return FilledButton(onPressed: null, child: Text(a.label));
              }
            }).toList(),
          ),
        ],
      ),
    );
  }
}
