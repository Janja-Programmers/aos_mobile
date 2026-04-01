import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';
import 'package:africaonlinestores/shared/enums/ads_mode.dart';

void openAllAds(
  BuildContext context, {
  String? categoryId,
  DealType? dealType,
  AdsSort? sort,
  AllAdsMode mode = AllAdsMode.normal,
}) {
  context.pushNamed(
    AppRoutes.nAllAds,
    queryParameters: {
      if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,

      if (dealType != null && dealType.apiValue != null)
        'promotion_type': dealType.apiValue!,

      if (sort != null) 'sort': sort.apiValue,

      if (mode == AllAdsMode.wishlist) 'mode': 'wishlist',
    },
  );
}
