import '../domain/entity/delivery_note.dart';
import '../domain/entity/delivery_note_item.dart';

class DeliveryNoteModel extends DeliveryNote {
  const DeliveryNoteModel({
    required super.id,
    required super.customerName,
    required super.status,
    required super.grandTotal,
    required super.percentInstalled,
    required super.items,
  });

  factory DeliveryNoteModel.fromJson(Map<String, dynamic> json) {
    return DeliveryNoteModel(
      id: json['name'],
      customerName: json['customer_name'] ?? '',
      status: json['status'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      percentInstalled: (json['per_installed'] as num?)?.toDouble() ?? 0.0,
      items:
          (json['items'] as List<dynamic>? ?? [])
              .map(
                (e) => DeliveryNoteItem(
                  itemCode: e['item_code'] ?? '',
                  itemName: e['item_name'] ?? '',
                  qty: (e['qty'] as num?)?.toInt() ?? 0,
                  rate: (e['rate'] as num?)?.toDouble() ?? 0.0,
                  amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
                ),
              )
              .toList(),
    );
  }
}
