import '../../../../shared/item/domain/item.dart';
import '../../../../shared/item/repository/item_repository.dart';

class CreateItem {
  final ItemRepository repository;

  CreateItem(this.repository);

  Future<void> call(Item item) => repository.createItem(item);
}
