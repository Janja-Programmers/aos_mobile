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
  bool _hasMore = true;
  bool _isLoading = false;
  String? _error;
  String _currentSearch = '';

  // --- Getters ---
  List<WebsiteItem> get items => _items;
  WebsiteItem? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  String get currentSearch => _currentSearch;

  // --- Initial Load / Search ---
  Future<void> searchItems(String query) async {
    _currentSearch = query;
    _currentPage = 1;
    _items.clear();
    _error = null;
    _hasMore = true;
    _isLoading = true;
    notifyListeners();

    await _fetchPage(_currentPage, _currentSearch);
  }

  // --- Refresh ---
  Future<void> refresh() async {
    await searchItems('');
  }

  // --- Pagination ---
  Future<void> nextPage() async {
    if (!_hasMore || _isLoading) return;
    _isLoading = true;
    notifyListeners();
    await _fetchPage(_currentPage + 1, _currentSearch);
  }

  Future<void> prevPage() async {
    if (_currentPage <= 1 || _isLoading) return;
    _isLoading = true;
    notifyListeners();
    await _fetchPage(_currentPage - 1, _currentSearch);
  }

  // --- Core Fetch ---
  Future<void> _fetchPage(int page, String search) async {
    try {
      final offset = (page - 1) * _itemsPerPage;
      final result = await getAllItems(start: offset, search: search);

      result.fold(
        (failure) {
          _error = failure.message;
        },
        (fetchedItems) {
          if (page == 1) {
            _items.clear();
          }
          _items.addAll(fetchedItems);
          _currentPage = page;
          _hasMore = fetchedItems.length == _itemsPerPage;
          _error = null;
        },
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
