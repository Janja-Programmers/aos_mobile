import '../domain/address.dart';

class AddressModel {
  final String name;
  final String title;
  final String line1;
  final String city;
  final String country;
  final String phone;
  final String type;
  final String? owner;

  AddressModel({
    required this.name,
    required this.title,
    required this.line1,
    required this.city,
    required this.country,
    required this.phone,
    required this.type,
    this.owner,
  });

  /// Converts to JSON for remote API (for POST only — no 'name')
  Map<String, dynamic> toJson() => {
    "address_title": title,
    "address_line1": line1,
    "city": city,
    "country": country,
    "phone": phone,
    "address_type": type,
    if (owner != null) "owner": owner,
  };

  /// Converts to a map for local SQLite (full object, including name)
  Map<String, dynamic> toMap() => {
    'name': name,
    'address_title': title,
    'address_line1': line1,
    'city': city,
    'country': country,
    'phone': phone,
    'address_type': type,
    'owner': owner,
  };

  /// Create from local SQLite map or remote response
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      name: map['name'] ?? '',
      title: map['address_title'] ?? '',
      line1: map['address_line1'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      phone: map['phone'] ?? '',
      type: map['address_type'] ?? '',
      owner: map['owner'],
    );
  }

  /// Convert back to domain entity
  Address toEntity() {
    return Address(
      name: name,
      title: title,
      line1: line1,
      city: city,
      country: country,
      phone: phone,
      type: type,
      owner: owner,
    );
  }

  /// Create from domain entity (used before POST)
  factory AddressModel.fromEntity(Address address) {
    return AddressModel(
      name: address.name,
      title: address.title,
      line1: address.line1,
      city: address.city,
      country: address.country.isNotEmpty ? address.country : "Kenya",
      phone: address.phone,
      type: address.type.isNotEmpty ? address.type : "Shipping",
      owner: address.owner, // 👈 keep owner when posting back
    );
  }

  @override
  String toString() {
    return 'AddressModel(line1: $line1, city: $city, country: $country, phone: $phone, owner: $owner)';
  }
}
