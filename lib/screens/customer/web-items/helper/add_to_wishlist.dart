import 'package:flutter/material.dart';

import '/core/utils/snackbar.dart';

import '/features/wishlist/domain/wishlist_item.dart';
import '/features/wishlist/provider.dart';

void handleToggleWishlist(
  BuildContext context,
  WishlistProvider provider,
  WishlistItem item,
) async {
  final result = await provider.toggleWishlist(item);

  if (result == null) {
    topSnackBar(context, 'Failed to update wishlist');
  } else if (result) {
    topSnackBar(context, '${item.title} added to wishlist');
  } else {
    topSnackBar(
      context,
      '${item.title} removed to wishlist',
      type: TopSnackType.error,
    );
  }
}
