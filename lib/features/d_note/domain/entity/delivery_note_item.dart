import 'package:equatable/equatable.dart';

class DeliveryNoteItem extends Equatable {
  final String itemCode;
  final String itemName;
  final int qty;
  final double rate;
  final double amount;

  const DeliveryNoteItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  @override
  List<Object?> get props => [itemCode, itemName, qty, rate, amount];
}
