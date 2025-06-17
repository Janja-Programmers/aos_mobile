import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import 'item_price.dart';

abstract class ItemPriceRepo {
  Future<Either<Failure, List<ItemPrice>>> getAll();
  Future<Either<Failure, ItemPrice>> create(ItemPrice itemPrice);
}
