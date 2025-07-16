// import 'package:flutter/foundation.dart';

// import 'domain/webitem.dart';
// import 'domain/usecases.dart';

// class WebsiteItemProv with ChangeNotifier {
//   final GetAllWebItemsUseCase getAllItems;
//   final GetSingleWebItemUseCase getSingleItem;

//   WebsiteItemProv({required this.getAllItems, required this.getSingleItem});

//   List<WebsiteItem> _items = [];
//   WebsiteItem? _selectedProduct;
//   bool _isLoading = false;
//   String? _error;

//   List<WebsiteItem> get items => _items;

//   WebsiteItem? get selectedProduct => _selectedProduct;

//   int _start = 0;
//   final int _limit = 12;
//   bool _hasMore = true;
//   bool _isLoadingMore = false;

//   bool get hasMore => _hasMore;
//   bool get isLoadingMore => _isLoadingMore;

//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> loadItems() async {
//     _start = 0;
//     _hasMore = true;
//     items.clear(); // reset
//     await _fetchItems();
//   }

//   Future<void> loadMoreItems() async {
//     if (_isLoadingMore || !_hasMore) return;
//     _isLoadingMore = true;
//     notifyListeners();
//     await _fetchItems();
//     _isLoadingMore = false;
//     notifyListeners();
//   }

//   Future<void> _fetchItems() async {
//     try {
//       isLoading = true;
//       notifyListeners();

//       final response = await repository.getProducts(
//         start: _start,
//         limit: _limit,
//       );

//       final newItems = response.getOrElse(() => []);
//       if (newItems.length < _limit) {
//         _hasMore = false;
//       }

//       items.addAll(newItems);
//       _start += _limit;
//       isLoading = false;
//       error = null;
//     } catch (e) {
//       error = 'Failed to load products';
//       isLoading = false;
//     } finally {
//       notifyListeners();
//     }
//   }

//   Future<void> loadItems() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     final result = await getAllItems();
//     result.fold(
//       (failure) => _error = failure.message,
//       (items) => _items = items,
//     );

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> loadProductDetail(String productId) async {
//     _error = null;
//     _selectedProduct = null;
//     _isLoading = true;
//     notifyListeners();

//     final result = await getSingleItem(productId);
//     result.fold(
//       (failure) {
//         _error = failure.message;
//         _selectedProduct = null;
//       },
//       (product) {
//         _selectedProduct = product;
//       },
//     );

//     _isLoading = false;
//     notifyListeners();
//   }

//   void clearProductDetail() {
//     _selectedProduct = null;
//     _error = null;
//     notifyListeners();
//   }
// }

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
