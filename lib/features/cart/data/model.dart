import '../domain/cart.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    required super.code,
    required super.name,
    required super.price,
    required super.quantity,
    super.image,
  });

  factory CartItemModel.fromEntity(CartItem item) => CartItemModel(
    code: item.code,
    name: item.name,
    price: item.price,
    quantity: item.quantity,
    image: item.image,
  );

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
    code: map['code'],
    name: map['name'],
    price: (map['price'] as num).toDouble(),
    quantity: map['quantity'],
    image: map['image'],
  );

  Map<String, dynamic> toMap() => {
    'code': code,
    'name': name,
    'price': price,
    'quantity': quantity,
    'image': image,
  };

  @override
  CartItem toEntity() => CartItem(
    code: code,
    name: name,
    price: price,
    quantity: quantity,
    image: image,
  );
}

extension CartItemX on CartItem {
  CartItemModel toModel() => CartItemModel(
    code: code,
    name: name,
    price: price,
    quantity: quantity,
    image: image,
  );
}
