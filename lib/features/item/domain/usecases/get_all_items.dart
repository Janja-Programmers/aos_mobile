import '../item.dart';
import '../item_repo.dart';

class GetAllItems {
  final ItemRepository repository;

  GetAllItems(this.repository);

  Future<List<Item>> call() async {
    return await repository.getAllItems();
  }
}
