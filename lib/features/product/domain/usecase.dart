import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'product.dart';
import 'repo.dart';

class GetProductsUseCase {
  final ProductRepo repo;

  GetProductsUseCase(this.repo);

  Future<Either<Failure, List<Product>>> call() async {
    return await repo.getProducts();
  }
}

class CreateProductUseCase {
  final ProductRepo repo;

  CreateProductUseCase(this.repo);

  Future<Either<Failure, Product>> call(Product product) async {
    return await repo.createProduct(product);
  }
}
