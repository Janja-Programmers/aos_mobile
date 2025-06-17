import 'package:equatable/equatable.dart';

class DeliveryNote extends Equatable {
  final String id;
  final String customerName;
  final String status;
  final double grandTotal;
  final double percentInstalled;

  const DeliveryNote({
    required this.id,
    required this.customerName,
    required this.status,
    required this.grandTotal,
    required this.percentInstalled,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    status,
    grandTotal,
    percentInstalled,
  ];
}
