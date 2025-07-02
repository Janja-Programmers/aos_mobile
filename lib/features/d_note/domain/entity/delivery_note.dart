import 'package:equatable/equatable.dart';

import 'delivery_note_item.dart';

class DeliveryNote extends Equatable {
  final String id;
  final String customerName;
  final String status;
  final double grandTotal;
  final double percentInstalled;
  final List<DeliveryNoteItem> items;

  const DeliveryNote({
    required this.id,
    required this.customerName,
    required this.status,
    required this.grandTotal,
    required this.percentInstalled,
    required this.items,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    status,
    grandTotal,
    percentInstalled,
    items,
  ];
}
