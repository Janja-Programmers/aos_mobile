import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import '../domain/item.dart';
import '../domain/usecases.dart';

class WebsiteItemProv with ChangeNotifier {
  final GetAllItemsUseCase getAllItems;

  WebsiteItemProv({required this.getAllItems});

  List<WebsiteItem> _items = [];
  List<WebsiteItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
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

  WebsiteItem? getItemById(String id) {
    return _items.firstWhereOrNull((item) => item.id == id);
  }
}
