import 'package:flutter/foundation.dart';

@immutable
class AOSPlace {
  final String id;
  final String name;
  final String displayAddress;
  final double latitude;
  final double longitude;
  final String? locality;
  final String? region;
  final String? country;
  final String? countryCode;
  final String? category;
  final String? type;

  const AOSPlace({
    required this.id,
    required this.name,
    required this.displayAddress,
    required this.latitude,
    required this.longitude,
    this.locality,
    this.region,
    this.country,
    this.countryCode,
    this.category,
    this.type,
  });

  String get shortLabel => name.isNotEmpty ? name : displayAddress;

  factory AOSPlace.fromJson(Map<String, dynamic> json) {
    final lat = _toDouble(json['latitude'] ?? json['lat']);
    final lon = _toDouble(json['longitude'] ?? json['lon']);
    final id =
        json['place_id']?.toString() ??
        json['id']?.toString() ??
        '${lat.toStringAsFixed(6)},${lon.toStringAsFixed(6)}';

    return AOSPlace(
      id: id,
      name: json['name']?.toString() ?? '',
      displayAddress:
          json['display_address']?.toString() ??
          json['address']?.toString() ??
          '',
      latitude: lat,
      longitude: lon,
      locality: json['locality']?.toString(),
      region: json['region']?.toString(),
      country: json['country']?.toString(),
      countryCode: json['country_code']?.toString(),
      category: json['category']?.toString(),
      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'name': name,
      'display_address': displayAddress,
      'latitude': latitude,
      'longitude': longitude,
      'locality': locality,
      'region': region,
      'country': country,
      'country_code': countryCode,
      'category': category,
      'type': type,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
