import 'package:africaonlinestores/features/wishlist/domain/wishlist_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistStorageProvider = Provider<WishlistStorage>((ref) {
  return WishlistStorage();
});
