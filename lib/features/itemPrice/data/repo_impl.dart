import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '/features/itemPrice/data/model.dart';

import '../domain/item_price.dart';
import '../domain/repo.dart';

import 'remote.dart';

class ItemPriceRepoImpl implements ItemPriceRepo {
  final ItemPriceRemoteDS remote;
  ItemPriceRepoImpl({required this.remote});

  @override
  Future<Either<Failure, List<ItemPrice>>> getAll() async {
    final result = await remote.getAll();
    // map() transforms the Right side only
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, ItemPrice>> create(ItemPrice itemPrice) async {
    final model = ItemPriceModel.fromEntity(itemPrice);
    final result = await remote.create(model);
    return result.map((m) => m.toEntity());
  }
}
