class CartItem {
  final String code;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.code,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  CartItem toEntity() =>
      CartItem(code: code, name: name, price: price, quantity: quantity);
}
