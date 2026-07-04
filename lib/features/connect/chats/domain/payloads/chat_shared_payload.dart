import 'dart:convert';

import 'package:africaonlinestores/core/utils/json_utils.dart';

const String chatLocationPayloadPrefix = 'aos_location_payload:';
const String chatContactPayloadPrefix = 'aos_contact_payload:';

class ChatLocationPayload {
  const ChatLocationPayload({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;

  bool get hasCoordinates => latitude != 0 || longitude != 0;

  String get title {
    final cleanName = name.trim();
    if (cleanName.isNotEmpty) return cleanName;

    final cleanAddress = address.trim();
    if (cleanAddress.isNotEmpty) return cleanAddress;

    if (hasCoordinates) {
      return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    }

    return 'Shared location';
  }

  String get subtitle {
    final cleanAddress = address.trim();
    if (cleanAddress.isNotEmpty && cleanAddress != title) {
      return cleanAddress;
    }

    if (hasCoordinates) {
      return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    }

    return 'Tap to open in AOS Maps';
  }

  String toMessageContent() {
    return '$chatLocationPayloadPrefix${jsonEncode(toJson())}';
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static ChatLocationPayload? tryParse(String? value) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty) return null;

    if (clean.startsWith(chatLocationPayloadPrefix)) {
      final encoded = clean.substring(chatLocationPayloadPrefix.length).trim();
      try {
        final decoded = jsonDecode(encoded) as Object?;
        final json = asJsonMap(decoded);
        if (json.isEmpty) return null;
        return ChatLocationPayload(
          name: _cleanString(json['name']),
          address: _cleanString(json['address']),
          latitude: _double(json['latitude']),
          longitude: _double(json['longitude']),
        );
      } on FormatException {
        return null;
      }
    }

    return _tryParseLegacyLocation(clean);
  }

  static ChatLocationPayload? _tryParseLegacyLocation(String value) {
    if (!value.contains('📍') && !value.toLowerCase().contains('location')) {
      return null;
    }

    final mapsMatch = RegExp(
      r'https?:\/\/maps\.google\.com\/\?q=([-+]?\d+(?:\.\d+)?),([-+]?\d+(?:\.\d+)?)',
    ).firstMatch(value);

    if (mapsMatch == null) return null;

    final lines = value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    final latitude = double.tryParse(mapsMatch.group(1) ?? '') ?? 0;
    final longitude = double.tryParse(mapsMatch.group(2) ?? '') ?? 0;
    final title = lines.length > 1 ? lines[1] : 'Shared location';
    final address = lines.length > 2 && !lines[2].startsWith('http')
        ? lines[2]
        : title;

    return ChatLocationPayload(
      name: title,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class ChatContactPayload {
  const ChatContactPayload({
    required this.displayName,
    this.user,
    this.avatar,
    this.phone,
    this.email,
  });

  final String displayName;
  final String? user;
  final String? avatar;
  final String? phone;
  final String? email;

  String get title {
    final cleanName = displayName.trim();
    if (cleanName.isNotEmpty) return cleanName;

    final cleanUser = user?.trim();
    if (cleanUser != null && cleanUser.isNotEmpty) return cleanUser;

    final cleanPhone = phone?.trim();
    if (cleanPhone != null && cleanPhone.isNotEmpty) return cleanPhone;

    return 'Shared contact';
  }

  String? get subtitle {
    final cleanPhone = phone?.trim();
    if (cleanPhone != null && cleanPhone.isNotEmpty) return cleanPhone;

    final cleanEmail = email?.trim();
    if (cleanEmail != null && cleanEmail.isNotEmpty) return cleanEmail;

    final cleanUser = user?.trim();
    if (cleanUser != null && cleanUser.isNotEmpty) return cleanUser;

    return null;
  }

  String get initials {
    final parts = title
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return _firstRune(parts.first).toUpperCase();

    return '${_firstRune(parts.first)}${_firstRune(parts.last)}'.toUpperCase();
  }

  bool get hasProfileTarget {
    final cleanUser = user?.trim();
    return cleanUser != null && cleanUser.isNotEmpty;
  }

  String toMessageContent() {
    return '$chatContactPayloadPrefix${jsonEncode(toJson())}';
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'display_name': displayName,
      'user': user,
      'avatar': avatar,
      'phone': phone,
      'email': email,
    };
  }

  static ChatContactPayload? tryParse(String? value) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty) return null;
    if (!clean.startsWith(chatContactPayloadPrefix)) return null;

    final encoded = clean.substring(chatContactPayloadPrefix.length).trim();
    try {
      final decoded = jsonDecode(encoded) as Object?;
      final json = asJsonMap(decoded);
      if (json.isEmpty) return null;
      return ChatContactPayload(
        displayName: _cleanString(json['display_name']),
        user: _cleanNullableString(json['user']),
        avatar: _cleanNullableString(json['avatar']),
        phone: _cleanNullableString(json['phone']),
        email: _cleanNullableString(json['email']),
      );
    } on FormatException {
      return null;
    }
  }
}

String _cleanString(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.toLowerCase() == 'null') return '';
  return text;
}

String? _cleanNullableString(Object? value) {
  final text = _cleanString(value);
  return text.isEmpty ? null : text;
}

double _double(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _firstRune(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return '?';
  return String.fromCharCode(clean.runes.first);
}
