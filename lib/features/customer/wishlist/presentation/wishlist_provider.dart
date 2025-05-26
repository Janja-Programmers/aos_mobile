import 'package:flutter/material.dart';

import '../domain/usecases/get_wishlist.dart';
import '../domain/usecases/remove_from_wishlist.dart';
import '../domain/usecases/add_to_wishlist.dart';
import '../domain/wishlist_item.dart';

class WishlistProvider extends ChangeNotifier {
  final GetWishlist getWishlist;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;

  WishlistProvider({
    required this.getWishlist,
    required this.addToWishlist,
    required this.removeFromWishlist,
  });

  List<WishlistItem> _items = [];
  List<WishlistItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await getWishlist();
    } catch (e) {
      _error = 'Failed to load wishlist';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> add(WishlistItem item) async {
    await addToWishlist(item);
    await loadWishlist(); // reload after change
  }

  Future<void> remove(String id) async {
    await removeFromWishlist(id);
    await loadWishlist();
  }

  bool isInWishlist(String id) {
    return _items.any((item) => item.id == id);
  }
}
