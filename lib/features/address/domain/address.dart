import 'package:africaonlinestores/core/di/service_locator.dart';
import 'package:africaonlinestores/screens/auth/auth_provider.dart';

class Address {
  final String name;
  final String title;
  final String line1;
  final String city;
  final String country;
  final String phone;
  final String type;
  final String? owner;

  Address({
    required this.name,
    required this.title,
    required this.line1,
    required this.city,
    required this.country,
    required this.phone,
    required this.type,
    this.owner,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] ?? '',
      title: json['address_title'] ?? '',
      line1: json['address_line1'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      type: json['address_type'] ?? '',
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() {
    final auth = sl<AuthProvider>();
    final ownerEmail = auth.user?.email ?? '';

    return {
      "address_title": title,
      "address_line1": line1,
      "city": city,
      "country": country,
      "phone": phone,
      "address_type": type,
      if (ownerEmail.isNotEmpty) "owner": ownerEmail,
    };
  }
}
