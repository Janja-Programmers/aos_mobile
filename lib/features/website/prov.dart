import 'package:flutter/foundation.dart';

import 'domain/webitem.dart';
import 'domain/usecases.dart';

class WebsiteItemProv with ChangeNotifier {
  final GetAllWebItemsUseCase getAllItems;
  final GetSingleWebItemUseCase getSingleItem;

  WebsiteItemProv({required this.getAllItems, required this.getSingleItem});

  List<WebsiteItem> _items = [];
  WebsiteItem? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  List<WebsiteItem> get items => _items;

  WebsiteItem? get selectedProduct => _selectedProduct;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getAllItems();
    result.fold(
      (failure) => _error = failure.message,
      (items) => _items = items,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProductDetail(String productId) async {
    _isLoading = true;
    _error = null;
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
}
