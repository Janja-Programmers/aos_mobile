import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/home/wishlist/domain/wishlist_storage.dart';

final wishlistStorageProvider = Provider<WishlistStorage>((ref) {
  return WishlistStorage();
});
