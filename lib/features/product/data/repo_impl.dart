import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../domain/product.dart';
import '../domain/repo.dart';

import 'model.dart';
import 'remote.dart';

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

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final createdModel = await remote.createProduct(model);
      final createdEntity = createdModel.toEntity();
      return Right(createdEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final updatedModel = await remote.updateProduct(model);
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
