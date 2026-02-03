import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

class AdCard extends StatelessWidget {
  const AdCard({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

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
      child: Container(
        width: 170,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: ad.coverImage.isEmpty
                    ? Container(
                        color: Theme.of(context).dividerColor.withOpacity(0.08),
                        child: const Icon(Icons.image_outlined),
                      )
                    : Image.network(
                        _toFullUrl(ad.coverImage),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.08),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              ad.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            const Spacer(),
            Text(
              _priceText(ad),
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _priceText(AOSAdListItem ad) {
  final type = ad.priceType.trim();
  if (type.toLowerCase() == 'free') return 'Free';
  if (type.toLowerCase() == 'contact for price') return 'Contact for price';
  if (ad.price == null) return '';

  final cur = ad.currency.trim();
  final p = ad.price!.toStringAsFixed(ad.price! % 1 == 0 ? 0 : 2);
  final unit = ad.priceUnit.trim();
  if (unit.isNotEmpty) return '$cur $p / $unit';
  return '$cur $p';
}

String _toFullUrl(String fileUrl) {
  final u = fileUrl.trim();
  if (u.startsWith('http://') || u.startsWith('https://')) return u;
  return u;
}
