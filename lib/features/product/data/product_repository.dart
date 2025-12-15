import 'product_model.dart';
import 'product_remote.dart';

class ProductRepository {
  final ProductRemote remote;

  ProductRepository(this.remote);

  Future<List<ProductModel>> getProducts() => remote.getProducts();
  
  Future<ProductModel> createProduct(ProductModel model) =>
      remote.createProduct(model);
  
  Future<ProductModel> updateProduct(ProductModel model) =>
      remote.updateProduct(model);

  Future<ProductModel?> getProductByName(String name) async {
    try {
      return await remote.getProductByName(name);
    } catch (_) {
      return null;
    }
  }
  
  Future<void> deleteProduct(String name) {
    return remote.deleteProduct(name);
  }
}
