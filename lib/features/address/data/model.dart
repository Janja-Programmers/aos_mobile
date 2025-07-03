import '../domain/address.dart';

class AddressModel {
  final String title;
  final String line1;
  final String city;
  final String country;
  final String phone;
  final String type;
  final String customer;

  AddressModel({
    required this.title,
    required this.line1,
    required this.city,
    required this.country,
    required this.phone,
    required this.type,
    required this.customer,
  });

  /// Converts to JSON for remote API
  Map<String, dynamic> toJson() => {
    "address_title": title,
    "address_line1": line1.toString(),
    "city": city,
    "country": country,
    "phone": phone,
    "address_type": type,
    "links": [
      {"link_doctype": "Customer", "link_name": title},
    ],
  };

  /// Converts to a map for local SQLite
  Map<String, dynamic> toMap() => {
    'address_title': title,
    'address_line1': line1,
    'city': city,
    'country': country,
    'phone': phone,
    'address_type': type,
    'customer': customer,
  };

  /// Create from local SQLite map
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      title: map['address_title'],
      line1: map['address_line1'],
      city: map['city'],
      country: map['country'],
      phone: map['phone'],
      type: map['address_type'],
      customer: map['customer'],
    );
  }

  /// Convert back to domain entity
  Address toEntity() {
    return Address(
      title: title,
      line1: line1,
      city: city,
      country: country,
      phone: phone,
      type: type,
      customer: customer,
    );
  }

  /// Create from domain entity
  factory AddressModel.fromEntity(Address entity) {
    return AddressModel(
      title: entity.title,
      line1: entity.line1,
      city: entity.city,
      country: entity.country,
      phone: entity.phone,
      type: entity.type,
      customer: entity.customer,
    );
  }
}
