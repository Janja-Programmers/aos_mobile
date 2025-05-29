import '../item.dart';
import '../item_repo.dart';

class CreateItem {
  final ItemRepository repository;

  CreateItem(this.repository);

  Future<void> call(Item item) async {
    await repository.createItem(item);
  }
}
