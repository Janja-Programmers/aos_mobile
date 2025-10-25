import '/features/address/data/model.dart';
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
    required super.postingDate,
    super.contactEmail,
    super.contactPhone,
    required super.shippingAddress,
  });

  factory DeliveryNoteModel.fromJson(Map<String, dynamic> json) {
    AddressModel parseAddressHtml(String? html) {
      if (html == null || html.trim().isEmpty) {
        return AddressModel(
          name: '',
          title: '',
          line1: '',
          city: '',
          country: '',
          phone: '',
          type: 'Shipping',
        );
      }

      final lines =
          html
              .replaceAll('<br />', '<br>')
              .split('<br>')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      String phone = '';
      for (final line in lines) {
        if (line.toLowerCase().startsWith('phone')) {
          phone = line.split(':').last.trim();
          break;
        }
      }

      final line1 = lines.isNotEmpty ? lines.first : '';
      final city = lines.length > 1 ? lines[1] : '';
      final country = lines.length > 2 ? lines[2] : '';

      return AddressModel(
        name: '',
        title: '',
        line1: line1,
        city: city,
        country: country,
        phone: phone,
        type: 'Shipping',
      );
    }

    final addressHtml =
        json['shipping_address_display'] ?? json['shipping_address'];
    final addressModel = parseAddressHtml(addressHtml);

    return DeliveryNoteModel(
      id: json['name'] ?? '',
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
      postingDate:
          DateTime.tryParse(json['posting_date'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      contactEmail: json['contact_email'],
      contactPhone: addressModel.phone,
      shippingAddress:
          (addressModel.line1.isNotEmpty
                  ? '${addressModel.line1}, ${addressModel.city}, ${addressModel.country}'
                  : (addressHtml ?? ''))
              .trim(),
    );
  }
}
