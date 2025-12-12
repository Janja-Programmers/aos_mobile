import 'package:flutter/material.dart';

import 'domain/usecases.dart';
import 'domain/wishlist_item.dart';

class WishlistProvider extends ChangeNotifier {
  final GetWishlist getWishlist;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;

  WishlistProvider({
    required this.getWishlist,
    required this.addToWishlist,
    required this.removeFromWishlist,
  });

  final List<WishlistItem> _items = [];
  List<WishlistItem> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int get count => _items.length;

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool isInWishlist(String id) {
    return _items.any((item) => item.id == id);
  }

  Future<void> loadWishlist() async {
    _setLoading(true);
    try {
      final result = await getWishlist();

      _items
        ..clear()
        ..addAll(result);

      _error = null;
    } catch (e) {
      _error = 'Failed to load wishlist: $e';
    }
    _setLoading(false);
  }

  Future<bool> add(WishlistItem item) async {
    if (isInWishlist(item.id)) return true;

    _items.add(item);
    notifyListeners();

    try {
      await addToWishlist(item);
      return true;
    } catch (e) {
      _items.removeWhere((i) => i.id == item.id);
      _error = 'Failed to add: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(String id) async {
    final existing = _items.where((i) => i.id == id).toList();
    if (existing.isEmpty) return true;

    _items.removeWhere((i) => i.id == id);
    notifyListeners();

    try {
      await removeFromWishlist(id);
      return true;
    } catch (e) {
      _items.addAll(existing);
      _error = 'Failed to remove: $e';
      notifyListeners();
      return false;
    }
  }

  /// Returns true if added, false if removed, null if failed.
  Future<bool?> toggleWishlist(WishlistItem item) async {
    if (isInWishlist(item.id)) {
      final removed = await remove(item.id);
      return removed ? false : null;
    } else {
      final added = await add(item);
      return added ? true : null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
