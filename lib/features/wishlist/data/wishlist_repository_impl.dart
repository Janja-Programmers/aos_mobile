import '../domain/wishlist_item.dart';
import '../domain/wishlist_repository.dart';
import 'wishlist_local_data_source.dart';
import 'wishlist_item_model.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDataSource localDataSource;

  WishlistRepositoryImpl(this.localDataSource);

  @override
  Future<List<WishlistItem>> getWishlist() async {
    return await localDataSource.getWishlistItems();
  }

  @override
  Future<void> addToWishlist(WishlistItem item) async {
    final currentItems = await localDataSource.getWishlistItems();

    // Prevent duplicate
    if (currentItems.any((e) => e.id == item.id)) return;

    final updated = [
      ...currentItems,
      WishlistItemModel(
        id: item.id,
        title: item.title,
        imageUrl: item.imageUrl,
        price: item.price,
      ),
    ];

    await localDataSource.saveWishlistItems(updated);
  }

  @override
  Future<void> removeFromWishlist(String id) async {
    final currentItems = await localDataSource.getWishlistItems();
    final updated = currentItems.where((item) => item.id != id).toList();
    await localDataSource.saveWishlistItems(updated);
  }
}
