import 'item.dart';

abstract class ItemRepository {
  Future<void> createItem(Item item);
  Future<List<Item>> getItemsByUser(int userId);
  Future<List<Item>> getAllItems();
}
