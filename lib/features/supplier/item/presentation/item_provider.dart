import 'package:flutter/material.dart';

import '../../../shared/item/domain/item.dart';
import '../../../shared/item/domain/usecases/get_items.dart';
import '../domain/usecases/update_item.dart';
import '../domain/usecases/delete_item.dart';
import '../domain/usecases/create_item.dart';

class ItemProvider with ChangeNotifier {
  final GetItems getItemsUseCase;
  final CreateItem createItemUseCase;
  final UpdateItem updateItemUseCase;
  final DeleteItem deleteItemUseCase;

  List<Item> _items = [];
  String currentUserId = 'seller123'; // Replace with real session/user

  List<Item> get items =>
      _items.where((i) => i.createdBy == currentUserId).toList();

  ItemProvider({
    required this.getItemsUseCase,
    required this.createItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
  });

  Future<void> loadItems() async {
    final allItems = await getItemsUseCase();
    _items = allItems;
    notifyListeners();
  }

  Future<void> addItem(Item item) async {
    await createItemUseCase(item);
    await loadItems();
  }

  Future<void> updateItem(String name, Item item) async {
    await updateItemUseCase(name, item);
    await loadItems();
  }

  Future<void> deleteItem(String name) async {
    await deleteItemUseCase(name);
    await loadItems();
  }

  Item? getItemByName(String itemName) {
    try {
      return _items.firstWhere((item) => item.itemName == itemName);
    } catch (_) {
      return null;
    }
  }
}
