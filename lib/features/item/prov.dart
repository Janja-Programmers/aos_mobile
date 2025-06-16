import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import 'domain/entity.dart';
import 'domain/usecases.dart';

class ItemProv with ChangeNotifier {
  final GetAllItemsUseCase getAllItems;
  final GetItemByNameUseCase getItemByName;
  final CreateItemUseCase createItem;
  final UpdateItemUseCase updateItem;

  ItemProv({
    required this.getAllItems,
    required this.getItemByName,
    required this.createItem,
    required this.updateItem,
  });

  List<Item> _items = [];
  List<Item> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ──────────────────────────────────────────────── LOAD ALL
  Future<void> loadItems() async {
    _setLoading(true);
    final result = await getAllItems();
    result.fold(
      (failure) => _error = failure.message,
      (fetched) => _items = fetched,
    );
    _setLoading(false);
  }

  // ──────────────────────────────────────────────── FETCH ONE (cached)
  Item? getItemById(String name) =>
      _items.firstWhereOrNull((item) => item.name == name);

  // ──────────────────────────────────────────────── ADD
  Future<bool> addItem(Item item) async {
    final result = await createItem(item);
    return result.fold(
      (f) {
        _error = f.message;
        return false;
      },
      (created) {
        _items.add(created);
        notifyListeners();
        return true;
      },
    );
  }

  // ──────────────────────────────────────────────── UPDATE
  Future<bool> updateExistingItem(Item item) async {
    final result = await updateItem(item);
    return result.fold(
      (f) {
        _error = f.message;
        return false;
      },
      (updated) {
        final index = _items.indexWhere((i) => i.name == updated.name);
        if (index != -1) {
          _items[index] = updated;
        } else {
          _items.add(updated);
        }
        notifyListeners();
        return true;
      },
    );
  }

  // ──────────────────────────────────────────────── Helpers
  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }
}
