import '../../../../shared/item/repository/item_repository.dart';
import '../../../../shared/item/domain/item.dart';

class UpdateItem {
  final ItemRepository repository;

  UpdateItem(this.repository);

  Future<void> call(String itemName, Item updatedItem) =>
      repository.updateItem(itemName, updatedItem);
}
