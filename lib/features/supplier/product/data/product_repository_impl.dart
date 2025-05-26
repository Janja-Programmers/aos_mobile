import '../../../shared/products/domain/product.dart';
import '../../../shared/products/domain/product_repository.dart';
import 'product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Product>> getProducts() async {
    return await remoteDataSource.fetchProducts();
  }

  @override
  Future<Product> getProductDetails(String id) async {
    return await remoteDataSource.fetchProductById(id);
  }
}
