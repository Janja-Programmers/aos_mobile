import 'package:dartz/dartz.dart';
import 'package:ownashop/core/utils/logger.dart';

import '/core/errors/failures.dart';
import '../domain/repo.dart';
import '../domain/webitem.dart';
import 'remote.dart';

class WebsiteRepoImpl implements WebsiteRepo {
  final WebsiteRemoteDataSource remote;

  WebsiteRepoImpl(this.remote);

  @override
  Future<Either<Failure, List<WebsiteItem>>> getAllItems() =>
      remote.fetchItems();

  @override
  Future<Either<Failure, WebsiteItem>> getOne(String id) {
    appLogger.i("Fetching product detail for ID: $id");
    appLogger.i(
      remote
          .fetchProductDetail(id)
          .then((either) => either.map((model) => model.toEntity())),
    );
    return remote
        .fetchProductDetail(id)
        .then((either) => either.map((model) => model.toEntity()));
  }
}
