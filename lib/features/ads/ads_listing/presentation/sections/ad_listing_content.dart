import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/ads_listing/utils/ad_listing_actions.dart';
import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:flutter/material.dart';

class AdListingContentView extends StatelessWidget {
  const AdListingContentView({
    super.key,
    required this.items,
    required this.tab,
    required this.onEdit,
    required this.onMarkSold,
    required this.onMarkAvailable,
    required this.onRenew,
    required this.onDelete,
    required this.onContactSupport,
  });

  final List<AOSAdListItem> items;
  final AdTab tab;

  final void Function(AOSAdListItem ad) onEdit;
  final void Function(AOSAdListItem ad) onMarkSold;
  final void Function(AOSAdListItem ad) onMarkAvailable;
  final void Function(AOSAdListItem ad) onRenew;
  final void Function(AOSAdListItem ad) onDelete;
  final void Function(AOSAdListItem ad) onContactSupport;

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
        onMarkAvailable: onMarkAvailable,
        onRenew: onRenew,
        onDelete: onDelete,
        onContactSupport: onContactSupport,
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
    required this.onMarkAvailable,
    required this.onRenew,
    required this.onDelete,
    required this.onContactSupport,
  });

  final AOSAdListItem ad;
  final AdTab tab;

  final void Function(AOSAdListItem ad) onEdit;
  final void Function(AOSAdListItem ad) onMarkSold;
  final void Function(AOSAdListItem ad) onMarkAvailable;
  final void Function(AOSAdListItem ad) onRenew;
  final void Function(AOSAdListItem ad) onDelete;
  final void Function(AOSAdListItem ad) onContactSupport;

  Future<void> _confirmDelete(BuildContext context) async {
    final title = ad.title.trim().isEmpty ? 'this listing' : ad.title.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.appColors.border,
          shadowColor: context.appColors.border,
          elevation: 1.5,
          title: Text('Delete Ad: $title'),
          content: const Text('This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancel', style: context.p),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('Delete', style: AppTextStylesX(context).button),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      onDelete(ad);
    }
  }

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
      onDelete: () => _confirmDelete(context),
      onMarkAvailable: onMarkAvailable,
      onRenew: onRenew,
      onContactSupport: onContactSupport,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
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
                  return IconButton.filledTonal(
                    tooltip: a.label,
                    onPressed: a.onPressed,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: colors.primary,
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
