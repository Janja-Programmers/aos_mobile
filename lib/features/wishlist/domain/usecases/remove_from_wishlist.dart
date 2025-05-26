import '../wishlist_repository.dart';

class RemoveFromWishlist {
  final WishlistRepository repository;

  RemoveFromWishlist(this.repository);

  Future<void> call(String id) async {
    await repository.removeFromWishlist(id);
  }
}
