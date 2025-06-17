import '../wishlist_item.dart';
import '../wishlist_repository.dart';

class GetWishlist {
  final WishlistRepository repository;

  GetWishlist(this.repository);

  Future<List<WishlistItem>> call() async {
    return await repository.getWishlist();
  }
}
