import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import 'entity.dart';
import 'repo.dart';

class GetAllItemsUseCase {
  final ItemRepo repo;

  GetAllItemsUseCase(this.repo);

  Future<Either<Failure, List<Item>>> call() async {
    return await repo.getAllItems();
  }
}
