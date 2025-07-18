import 'package:flutter/foundation.dart';

import 'domain/webitem.dart';
import 'domain/usecases.dart';

class WebsiteItemProv with ChangeNotifier {
  final GetAllWebItemsUseCase getAllItems;
  final GetSingleWebItemUseCase getSingleItem;

  WebsiteItemProv({required this.getAllItems, required this.getSingleItem});

  final List<WebsiteItem> _items = [];
  WebsiteItem? _selectedProduct;

  int _start = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  List<WebsiteItem> get items => _items;
  WebsiteItem? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadInitialItems() async {
    _start = 0;
    _hasMore = true;
    _items.clear();
    _error = null;
    _isLoading = true;
    notifyListeners();

    final result = await getAllItems(start: _start);
    result.fold((failure) => _error = failure.message, (fetchedItems) {
      _items.addAll(fetchedItems);
      _start += fetchedItems.length;
      if (fetchedItems.length < 12) _hasMore = false;
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreItems() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final result = await getAllItems(start: _start);
    result.fold((failure) => _error = failure.message, (fetchedItems) {
      _items.addAll(fetchedItems);
      _start += fetchedItems.length;
      if (fetchedItems.length < 12) _hasMore = false;
    });

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadProductDetail(String productId) async {
    _error = null;
    _selectedProduct = null;
    _isLoading = true;
    notifyListeners();

    final result = await getSingleItem(productId);
    result.fold(
      (failure) {
        _error = failure.message;
        _selectedProduct = null;
      },
      (product) {
        _selectedProduct = product;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearProductDetail() {
    _selectedProduct = null;
    _error = null;
    notifyListeners();
  }
}
