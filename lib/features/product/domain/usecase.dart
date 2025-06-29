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

class GetVendorProductsUseCase {
  final ProductRepo repo;

  GetVendorProductsUseCase(this.repo);

  Future<Either<Failure, List<Product>>> call(String vendor) async {
    return await repo.getProductsByVendor(vendor);
  }
}

class CreateProductUseCase {
  final ProductRepo repo;

  CreateProductUseCase(this.repo);

  Future<Either<Failure, Product>> call(Product product) async {
    return await repo.createProduct(product);
  }
}
