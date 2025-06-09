import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '../domain/repo.dart';
import '../domain/entity.dart';
import 'remote.dart';

class ItemRepoImpl implements ItemRepo {
  final ItemRemoteDataSource remote;

  ItemRepoImpl(this.remote);

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async {
    return await remote.fetchItems();
  }
}
