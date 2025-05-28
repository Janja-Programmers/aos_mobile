import '../../../../shared/item/repository/item_repository.dart';

class DeleteItem {
  final ItemRepository repository;

  DeleteItem(this.repository);

  Future<void> call(String itemName) => repository.deleteItem(itemName);
}
