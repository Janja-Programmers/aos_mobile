import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '../domain/repo.dart';
import '../domain/entity.dart';
import 'remote.dart';

class ItemRepoImpl implements ItemRepo {
  final ItemRemoteDataSource remote;

  ItemRepoImpl(this.remote);

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async {
    return await remote.fetchItems();
  }

  @override
  Future<Either<Failure, Item>> getItemByName(String name) async {
    return await remote.fetchItemByName(name);
  }

  @override
  Future<Either<Failure, Item>> addItem(Item item) async {
    return await remote.createItem(item);
  }

  @override
  Future<Either<Failure, Item>> updateItem(Item item) async {
    return await remote.updateItem(item);
  }
}
