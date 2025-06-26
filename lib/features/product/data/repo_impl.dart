import 'package:dartz/dartz.dart';
import 'package:ownashop/core/errors/failures.dart';
import 'package:ownashop/features/product/data/remote.dart';
import 'package:ownashop/features/product/domain/product.dart';
import 'package:ownashop/features/product/domain/repo.dart';

class ProductRepoImpl implements ProductRepo {
  final ProductRemoteDataSource remote;

  ProductRepoImpl(this.remote);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final models = await remote.getProducts();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
