import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'product.dart';

abstract class ProductRepo {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> createProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
}
