import '../domain/item.dart';

abstract class ItemRepository {
  Future<void> createItem(Item item);
  Future<List<Item>> getItems();
  Future<Item?> getItemByName(String itemName);
  Future<void> updateItem(String itemName, Item item);
  Future<void> deleteItem(String itemName);
}
