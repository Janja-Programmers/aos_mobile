import '../domain/cart.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    super.code,
    required super.name,
    required super.price,
    required super.quantity,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
    code: map['code'],
    name: map['name'],
    price: map['price'],
    quantity: map['quantity'],
  );

  Map<String, dynamic> toMap() => {
    'code': code,
    'name': name,
    'price': price,
    'quantity': quantity,
  };
}
