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
  final String? source;
  final String? instructions;
  final String? updatedAt;
  final bool hasLocation;

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
    this.source,
    this.instructions,
    this.updatedAt,
    this.hasLocation = true,
  });

  String get shortLabel => name.isNotEmpty ? name : displayAddress;

  factory AOSPlace.fromJson(Map<String, dynamic> json) {
    final lat = _toDouble(json['latitude'] ?? json['lat']);
    final lon = _toDouble(json['longitude'] ?? json['lon']);
    final id =
        _string(json['place_id']) ??
        _string(json['id']) ??
        '${lat.toStringAsFixed(6)},${lon.toStringAsFixed(6)}';

    final name =
        _string(json['name']) ??
        _string(json['location_name']) ??
        _string(json['title']) ??
        '';
    final address =
        _string(json['display_address']) ??
        _string(json['address']) ??
        _string(json['formatted_address']) ??
        '';

    return AOSPlace(
      id: id,
      name: name,
      displayAddress: address,
      latitude: lat,
      longitude: lon,
      locality: _string(json['locality']),
      region: _string(json['region']),
      country: _string(json['country']),
      countryCode: _string(json['country_code']),
      category: _string(json['category']),
      type: _string(json['type']),
      source: _string(json['source']),
      instructions:
          _string(json['instructions']) ??
          _string(json['location_instructions']),
      updatedAt: _string(json['updated_at']),
      hasLocation: _toBool(
        json['has_location'],
        fallback: lat != 0 || lon != 0,
      ),
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
      'source': source,
      'instructions': instructions,
      'updated_at': updatedAt,
      'has_location': hasLocation,
    };
  }

  AOSPlace copyWith({
    String? id,
    String? name,
    String? displayAddress,
    double? latitude,
    double? longitude,
    String? locality,
    String? region,
    String? country,
    String? countryCode,
    String? category,
    String? type,
    String? source,
    String? instructions,
    String? updatedAt,
    bool? hasLocation,
  }) {
    return AOSPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      displayAddress: displayAddress ?? this.displayAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locality: locality ?? this.locality,
      region: region ?? this.region,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      category: category ?? this.category,
      type: type ?? this.type,
      source: source ?? this.source,
      instructions: instructions ?? this.instructions,
      updatedAt: updatedAt ?? this.updatedAt,
      hasLocation: hasLocation ?? this.hasLocation,
    );
  }

  static String? _string(dynamic value) {
    final v = value?.toString().trim();
    if (v == null || v.isEmpty || v == 'null') return null;
    return v;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final clean = value.toString().trim().toLowerCase();
    return clean == '1' || clean == 'true' || clean == 'yes';
  }
}
