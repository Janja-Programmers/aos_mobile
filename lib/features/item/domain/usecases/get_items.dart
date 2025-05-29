import '../item.dart';
import '../item_repo.dart';

class GetItems {
  final ItemRepository repository;

  GetItems(this.repository);

  Future<List<Item>> call(int userId) async {
    return await repository.getItemsByUser(userId);
  }
}
