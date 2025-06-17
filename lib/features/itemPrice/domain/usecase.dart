import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import 'item_price.dart';
import 'repo.dart';

class GetAllItemPrices {
  final ItemPriceRepo repo;
  GetAllItemPrices(this.repo);

  Future<Either<Failure, List<ItemPrice>>> call() async {
    return await repo.getAll();
  }
}

class CreateItemPrice {
  final ItemPriceRepo repo;
  CreateItemPrice(this.repo);

  Future<Either<Failure, ItemPrice>> call(ItemPrice itemPrice) async {
    return await repo.create(itemPrice);
  }
}
