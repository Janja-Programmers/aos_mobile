import '../domain/item.dart';
import '../domain/item_repo.dart';
import 'datasource/item_local_datasource.dart';
import 'item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemLocalDataSource localDataSource;

  ItemRepositoryImpl(this.localDataSource);

  @override
  Future<void> createItem(Item item) async {
    final itemModel = ItemModel(
      itemCode: item.itemCode,
      itemName: item.itemName,
      itemGroup: item.itemGroup,
      company: item.company,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
    );
    await localDataSource.insertItem(itemModel);
  }

  @override
  Future<List<Item>> getItemsByUser(int userId) async {
    final data = await localDataSource.getItemsByUser(userId);
    return data.map((e) => e as Item).toList();
  }

  @override
  Future<List<Item>> getAllItems() async {
    final data = await localDataSource.getAllItems();
    return data.map((e) => e as Item).toList();
  }
}
