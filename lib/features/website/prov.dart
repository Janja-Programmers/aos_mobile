import 'package:flutter/foundation.dart';
import 'domain/webitem.dart';
import 'domain/usecases.dart';

class WebsiteItemProv with ChangeNotifier {
  final GetAllWebItemsUseCase getAllItems;
  final GetSingleWebItemUseCase getSingleItem;

  WebsiteItemProv({required this.getAllItems, required this.getSingleItem});

  // --- Core Data ---
  final List<WebsiteItem> _items = [];
  WebsiteItem? _selectedProduct;

  // --- Pagination State ---
  int _currentPage = 1;
  final int _itemsPerPage = 12;
  int _totalItems = 0;
  bool _hasMore = true;

  // --- Loading & Error State ---
  bool _isLoading = false;
  String? _error;

  // --- Getters ---
  List<WebsiteItem> get items => _items;
  WebsiteItem? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();

  // --- Initial Load ---
  Future<void> loadInitialItems() async {
    _currentPage = 1;
    _items.clear();
    _error = null;
    _hasMore = true;
    _isLoading = true;
    notifyListeners();

    await _fetchItems(page: _currentPage);
  }

  // --- Core Fetch Logic (used by next/prev) ---
  Future<void> _fetchItems({required int page}) async {
    final offset = (page - 1) * _itemsPerPage;
    final result = await getAllItems(start: offset);

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (fetchedItems) {
        _items
          ..clear()
          ..addAll(fetchedItems);

        _totalItems =
            _totalItems == 0
                ? (fetchedItems.length < _itemsPerPage
                    ? fetchedItems.length
                    : _itemsPerPage * (page + 2))
                : _totalItems;

        _currentPage = page;
        _hasMore = fetchedItems.length == _itemsPerPage;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // --- Pagination Controls ---
  Future<void> nextPage() async {
    if (!_hasMore || _isLoading) return;
    _isLoading = true;
    notifyListeners();
    await _fetchItems(page: _currentPage + 1);
  }

  Future<void> prevPage() async {
    if (_currentPage <= 1 || _isLoading) return;
    _isLoading = true;
    notifyListeners();
    await _fetchItems(page: _currentPage - 1);
  }

  // --- Product Details ---
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

  // --- Utilities ---
  void clearProductDetail() {
    _selectedProduct = null;
    _error = null;
    notifyListeners();
  }

  void silentClearProductDetail() {
    _selectedProduct = null;
    _error = null;
  }
}
