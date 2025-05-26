import '../product.dart';
import '../product_repository.dart';

class GetProductDetails {
  final ProductRepository repository;

  GetProductDetails(this.repository);

  Future<Product> call(String id) async {
    return await repository.getProductDetails(id);
  }
}
