import 'package:flutter/material.dart';
import '../domain/item.dart';
import '../domain/usecases/create_item.dart';
import '../domain/usecases/get_items.dart';

class ItemProvider with ChangeNotifier {
  final CreateItem createItemUsecase;
  final GetItems getItemsUsecase;

  List<Item> _items = [];
  List<Item> get items => _items;

  bool _loading = false;
  bool get isLoading => _loading;

  ItemProvider({
    required this.createItemUsecase,
    required this.getItemsUsecase,
  });

  Future<void> addItem(Item item) async {
    _loading = true;
    notifyListeners();

    await createItemUsecase(item);
    _items.add(item);

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchItems(int userId) async {
    _loading = true;
    notifyListeners();

    _items = await getItemsUsecase(userId);

    _loading = false;
    notifyListeners();
  }
}
