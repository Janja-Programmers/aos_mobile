import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';

import 'package:africaonlinestores/shared/widgets/app_network_image.dart';

class AdListTile extends StatelessWidget {
  const AdListTile({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = buildPriceDisplay(ad);

    return ListTile(
      onTap: onTap,
      leading: ad.primaryImage.isEmpty
          ? const Icon(Icons.image)
          : AppNetworkImage(url: ad.primaryImage),

      title: Text(ad.title),

      subtitle: price.show
          ? Row(
              children: [
                Text(
                  price.current!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (price.original != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    price.original!,
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            )
          : null,
    );
  }
}
