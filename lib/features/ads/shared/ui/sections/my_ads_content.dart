import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class MyAdsContentView extends StatelessWidget {
  const MyAdsContentView({
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
    final url = buildFileUrl(ad.coverImage);
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
                  child: ad.coverImage.isEmpty
                      ? Container(color: scheme.surface)
                      : Image.network(
                          url ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.category_outlined,
                            color: scheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.pStrong,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ad.locationName}, ${ad.country}',
                      style: context.pMuted.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ad.currency} ${ad.price.toString()}',
                      style: context.pStrong,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                      color: Colors.white,
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
