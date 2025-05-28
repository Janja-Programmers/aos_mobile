import '../../repository/item_repository.dart';
import '../item.dart';

class GetItemByName {
  final ItemRepository repository;

  GetItemByName(this.repository);

  Future<Item?> call(String itemName) => repository.getItemByName(itemName);
}
