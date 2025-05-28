import '../../repository/item_repository.dart';
import '../item.dart';

class GetItems {
  final ItemRepository repository;

  GetItems(this.repository);

  Future<List<Item>> call() => repository.getItems();
}
