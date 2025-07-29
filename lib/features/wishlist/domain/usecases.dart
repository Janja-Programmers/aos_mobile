import 'wishlist_item.dart';
import 'wishlist_repo.dart';

class GetWishlist {
  final WishlistRepo repository;

  GetWishlist(this.repository);

  Future<List<WishlistItem>> call() async {
    return await repository.getWishlist();
  }
}

class AddToWishlist {
  final WishlistRepo repository;

  AddToWishlist(this.repository);

  Future<void> call(WishlistItem item) async {
    await repository.addToWishlist(item);
  }
}

class RemoveFromWishlist {
  final WishlistRepo repository;

  RemoveFromWishlist(this.repository);

  Future<void> call(String id) async {
    await repository.removeFromWishlist(id);
  }
}
