import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import 'entity.dart';

abstract class ItemRepo {
  Future<Either<Failure, List<Item>>> getAllItems();
  Future<Either<Failure, Item>> getItemByName(String name);
  Future<Either<Failure, Item>> addItem(Item item);
  Future<Either<Failure, Item>> updateItem(Item item);
  // Future<Either<Failure, void>> deleteItem(String id);

  // Add more methods as needed for your specific use case
}
