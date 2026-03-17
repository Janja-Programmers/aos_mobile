import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';

void openAllAds(
  BuildContext context, {
  String? categoryId,
  DealType? dealType,
  AllAdsMode mode = AllAdsMode.normal,
}) {
  context.pushNamed(
    AppRoutes.nAllAds,
    queryParameters: {
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (dealType != null && dealType != DealType.all)
        'dealType': dealType.apiValue!,
      if (mode == AllAdsMode.wishlist) 'mode': 'wishlist',
    },
  );
}
