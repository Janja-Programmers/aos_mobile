import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import 'domain/webitem.dart';
import 'domain/usecases.dart';

class WebsiteItemProv with ChangeNotifier {
  final GetAllWebItemsUseCase getAllItems;
  final CreateWebItemUseCase createItem;
  final UpdateWebItemUseCase updateItem;

  WebsiteItemProv({
    required this.getAllItems,
    required this.createItem,
    required this.updateItem,
  });

  List<WebsiteItem> _items = [];
  List<WebsiteItem> get items => _items;

  bool _isLoading = false;
  String? _error;

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

  Future<bool> addItem(WebsiteItem item) async {
    final result = await createItem(item);
    return result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (newItem) {
        _items.add(newItem);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateExistingItem(String id, WebsiteItem item) async {
    final result = await updateItem(id, item);
    return result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (updatedItem) {
        final index = _items.indexWhere((e) => e.id == id);
        if (index != -1) {
          _items[index] = updatedItem;
          notifyListeners();
        }
        return true;
      },
    );
  }

  WebsiteItem? getItemById(String id) =>
      _items.firstWhereOrNull((item) => item.id == id);
}
