import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import 'item.dart';
import 'repo.dart';

class GetAllItemsUseCase {
  final WebsiteRepo repo;

  GetAllItemsUseCase(this.repo);

  Future<Either<Failure, List<WebsiteItem>>> call() async {
    return await repo.getAllItems();
  }
}
