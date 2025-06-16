import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import 'entity.dart';
import 'repo.dart';

class GetAllItemsUseCase {
  final ItemRepo repo;
  GetAllItemsUseCase(this.repo);

  Future<Either<Failure, List<Item>>> call() => repo.getAllItems();
}

class GetItemByNameUseCase {
  final ItemRepo repo;
  GetItemByNameUseCase(this.repo);

  Future<Either<Failure, Item>> call(String name) => repo.getItemByName(name);
}

class CreateItemUseCase {
  final ItemRepo repo;
  CreateItemUseCase(this.repo);

  Future<Either<Failure, Item>> call(Item item) => repo.addItem(item);
}

class UpdateItemUseCase {
  final ItemRepo repo;
  UpdateItemUseCase(this.repo);

  Future<Either<Failure, Item>> call(Item item) => repo.updateItem(item);
}
