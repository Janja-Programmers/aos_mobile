import 'package:dartz/dartz.dart';
import 'package:ownashop/core/errors/failures.dart';

import 'item.dart';

abstract class ItemRepository {
  Future<void> createItem(Item item);
  Future<List<Item>> getItemsByUser(int userId);
  Future<List<Item>> getAllItems();
  Future<Either<Failure, Item>> getItemByCode(String itemCode);
}
