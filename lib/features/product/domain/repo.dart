import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'product.dart';

abstract class ProductRepo {
  Future<Either<Failure, List<Product>>> getProducts();
}
