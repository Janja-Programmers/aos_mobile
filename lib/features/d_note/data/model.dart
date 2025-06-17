import '../domain/delivery_note.dart';

class DeliveryNoteModel extends DeliveryNote {
  const DeliveryNoteModel({
    required super.id,
    required super.customerName,
    required super.status,
    required super.grandTotal,
    required super.percentInstalled,
  });

  factory DeliveryNoteModel.fromJson(Map<String, dynamic> json) {
    return DeliveryNoteModel(
      id: json['name'],
      customerName: json['customer_name'] ?? '',
      status: json['status'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      percentInstalled: (json['per_installed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
