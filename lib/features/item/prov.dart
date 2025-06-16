import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import 'domain/entity.dart';
import 'domain/usecases.dart';

class ItemProv with ChangeNotifier {
  final GetAllItemsUseCase getAllItems;

  ItemProv({required this.getAllItems});

  List<Item> _items = [];
  List<Item> get items => _items;

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

  Item? getItemById(String name) {
    return _items.firstWhereOrNull((item) => item.name == name);
  }
}
