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

  CartItem copyWith({
    String? code,
    String? name,
    double? price,
    int? quantity,
    String? image,
  }) {
    return CartItem(
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartItem && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
