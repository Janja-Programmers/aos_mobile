import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'webitem.dart';
import 'repo.dart';

class GetAllWebItemsUseCase {
  final WebsiteRepo repo;

  GetAllWebItemsUseCase(this.repo);

  Future<Either<Failure, List<WebsiteItem>>> call({required int start}) {
    return repo.getAllItems(start: start);
  }
}

class GetSingleWebItemUseCase {
  final WebsiteRepo repo;

  GetSingleWebItemUseCase(this.repo);

  Future<Either<Failure, WebsiteItem>> call(dynamic id) async {
    return await repo.getOne(id);
  }
}
