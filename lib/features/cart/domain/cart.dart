class CartItem {
  final String code;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  CartItem({
    required this.code,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  double get subtotal => price * quantity;

  CartItem toEntity() => CartItem(
    code: code,
    name: name,
    price: price,
    quantity: quantity,
    image: image,
  );

  Map<String, dynamic> toJson() => {
    "item_code": code,
    "qty": quantity,
    "rate": price,
  };
}
