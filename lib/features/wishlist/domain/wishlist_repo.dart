import 'wishlist_item.dart';

abstract class WishlistRepo {
  Future<List<WishlistItem>> getWishlist();
  Future<void> addToWishlist(WishlistItem item);
  Future<void> removeFromWishlist(String id);
}
