import '../domain/item.dart';
import '../repository/item_repository.dart';
import 'item_local_datasource.dart';
import 'item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemLocalDataSource localDataSource;

  ItemRepositoryImpl(this.localDataSource);

  @override
  Future<List<Item>> getItems() async {
    return await localDataSource.getItems();
  }

  @override
  Future<Item?> getItemByName(String itemName) async {
    return await localDataSource.getItemByName(itemName);
  }

  @override
  Future<void> createItem(Item item) async {
    final model = ItemModel(
      itemName: item.itemName,
      itemGroup: item.itemGroup,
      company: item.company,
      createdBy: item.createdBy,
    );
    await localDataSource.insertItem(model);
  }

  @override
  Future<void> updateItem(String itemName, Item item) async {
    final model = ItemModel(
      itemName: item.itemName,
      itemGroup: item.itemGroup,
      company: item.company,
      createdBy: item.createdBy,
    );
    await localDataSource.updateItem(itemName, model);
  }

  @override
  Future<void> deleteItem(String itemName) async {
    await localDataSource.deleteItem(itemName);
  }
}
