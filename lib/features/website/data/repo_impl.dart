import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../domain/repo.dart';
import '../domain/webitem.dart';

import 'remote.dart';

class WebsiteRepoImpl implements WebsiteRepo {
  final WebsiteRemoteDataSource remote;

  WebsiteRepoImpl(this.remote);

  @override
  Future<Either<Failure, List<WebsiteItem>>> getAllItems({required int start}) {
    return remote.fetchItems(start: start);
  }

  @override
  Future<Either<Failure, WebsiteItem>> getOne(String id) {
    return remote
        .fetchProductDetail(id)
        .then((either) => either.map((model) => model.toEntity()));
  }
}
