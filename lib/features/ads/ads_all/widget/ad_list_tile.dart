import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

import 'package:africaonlinestores/shared/widgets/app_network_image.dart';

class AdListTile extends StatelessWidget {
  const AdListTile({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = resolveAdPrice(ad);
    final imageUrl = buildFileUrl(ad.primaryImage);

    return ListTile(
      onTap: onTap,

      /// IMAGE
      leading: imageUrl == null || imageUrl.isEmpty
          ? const Icon(Icons.image)
          : AppNetworkImage(url: imageUrl),

      /// TITLE
      title: Text(ad.title, maxLines: 2, overflow: TextOverflow.ellipsis),

      /// PRICE
      subtitle: price.show
          ? Row(
              children: [
                Text(
                  price.current ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                if (price.original != null && price.original!.isNotEmpty) ...[
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
