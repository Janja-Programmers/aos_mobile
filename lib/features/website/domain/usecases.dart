import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'webitem.dart';
import 'repo.dart';

class GetAllWebItemsUseCase {
  final WebsiteRepo repo;

  GetAllWebItemsUseCase(this.repo);

  Future<Either<Failure, List<WebsiteItem>>> call() async {
    return await repo.getAllItems();
  }
}

class CreateWebItemUseCase {
  final WebsiteRepo repo;

  CreateWebItemUseCase(this.repo);

  Future<Either<Failure, WebsiteItem>> call(WebsiteItem item) async {
    return await repo.createItem(item);
  }
}

class UpdateWebItemUseCase {
  final WebsiteRepo repo;

  UpdateWebItemUseCase(this.repo);

  Future<Either<Failure, WebsiteItem>> call(String id, WebsiteItem item) async {
    return await repo.updateItem(id, item);
  }
}
