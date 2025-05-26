import 'dart:async';
import 'product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
  Future<ProductModel> fetchProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final List<Map<String, dynamic>> _mockedJson = [
    {
      'id': '1',
      'title': 'Wireless Headphones',
      'description': 'Noise-cancelling over-ear Bluetooth headphones.',
      'price': 59.99,
      'oldPrice': 79.99,
      'imageUrl':
          'https://images.pexels.com/photos/4887161/pexels-photo-4887161.jpeg?auto=compress&cs=tinysrgb&w=600',
      'category': 'Electronics',
      'shopName': 'SoundHouse',
      'sellerName': 'Lena Audio',
      'phoneNumber': '+1234567890',
      'rating': 4.5,
      'inStock': true,
    },
    {
      'id': '2',
      'title': 'Smart Watch',
      'description': 'Fitness tracking smart watch with heart rate monitor.',
      'price': 99.99,
      'oldPrice': null,
      'imageUrl':
          'https://images.pexels.com/photos/2779018/pexels-photo-2779018.jpeg?auto=compress&cs=tinysrgb&w=600',
      'category': 'Electronics',
      'shopName': 'FitPro',
      'sellerName': 'Eli Tech',
      'phoneNumber': '+1234567891',
      'rating': 4.2,
      'inStock': true,
    },
    {
      'id': '3',
      'title': 'Running Shoes',
      'description': 'Lightweight shoes designed for runners.',
      'price': 49.99,
      'oldPrice': 69.99,
      'imageUrl':
          'https://images.pexels.com/photos/1027130/pexels-photo-1027130.jpeg?auto=compress&cs=tinysrgb&w=600',
      'category': 'Fashion',
      'shopName': 'FastFeet',
      'sellerName': 'John Sport',
      'phoneNumber': '+1234567892',
      'rating': 4.6,
      'inStock': true,
    },
    {
      'id': '4',
      'title': 'Leather Wallet',
      'description': 'Compact leather wallet with RFID blocking.',
      'price': 25.00,
      'oldPrice': null,
      'imageUrl':
          'https://images.pexels.com/photos/4386178/pexels-photo-4386178.jpeg?auto=compress&cs=tinysrgb&w=600',
      'category': 'Fashion',
      'shopName': 'WalletCraft',
      'sellerName': 'Derek Leather',
      'phoneNumber': '+1234567893',
      'rating': 4.0,
      'inStock': false,
    },
    {
      'id': '5',
      'title': 'LED Desk Lamp',
      'description': 'Adjustable desk lamp with USB charging port.',
      'price': 32.50,
      'oldPrice': 39.99,
      'imageUrl':
          'https://images.pexels.com/photos/974746/pexels-photo-974746.jpeg?auto=compress&cs=tinysrgb&w=600',
      'category': 'Home',
      'shopName': 'BrightLite',
      'sellerName': 'Angela Home',
      'phoneNumber': '+1234567894',
      'rating': 4.3,
      'inStock': true,
    },
    {
      'id': '6',
      'title': 'Cotton T-Shirts (3 Pack)',
      'description': '100% cotton t-shirts for everyday wear.',
      'price': 19.99,
      'oldPrice': 24.99,
      'imageUrl':
          'https://images.pexels.com/photos/6256263/pexels-photo-6256263.jpeg?auto=compress&cs=tinysrgb&w=600',
      'category': 'Fashion',
      'shopName': 'WearEase',
      'sellerName': 'Tina Style',
      'phoneNumber': '+1234567895',
      'rating': 3.9,
      'inStock': true,
    },
    {
      'id': '7',
      'title': 'Bluetooth Speaker',
      'description': 'Portable speaker with deep bass and 10-hour battery.',
      'price': 45.00,
      'oldPrice': 55.00,
      'imageUrl':
          'https://images.pexels.com/photos/14309813/pexels-photo-14309813.jpeg?auto=compress&cs=tinysrgb&w=600',
      'category': 'Electronics',
      'shopName': 'BoomSound',
      'sellerName': 'Rick Beats',
      'phoneNumber': '+1234567896',
      'rating': 4.7,
      'inStock': true,
    },
  ];

  @override
  Future<List<ProductModel>> fetchProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockedJson.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> fetchProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final json = _mockedJson.firstWhere((item) => item['id'] == id);
    return ProductModel.fromJson(json);
  }
}
