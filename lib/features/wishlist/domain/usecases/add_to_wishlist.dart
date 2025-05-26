import '../wishlist_item.dart';
import '../wishlist_repository.dart';

class AddToWishlist {
  final WishlistRepository repository;

  AddToWishlist(this.repository);

  Future<void> call(WishlistItem item) async {
    await repository.addToWishlist(item);
  }
}
