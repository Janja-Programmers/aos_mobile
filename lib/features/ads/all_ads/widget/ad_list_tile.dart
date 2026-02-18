import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/widgets/app_network_image.dart';

import 'package:africaonlinestores/features/home/utils/helpers.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

class AdListTile extends StatelessWidget {
  const AdListTile({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ad.coverImage.isEmpty
          ? const Icon(Icons.image)
          : AppNetworkImage(url: ad.coverImage),

      title: Text(ad.title),
      subtitle: Text(priceText(ad)),
    );
  }
}
