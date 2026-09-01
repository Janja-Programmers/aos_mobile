import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';

class SellerLocationResponse {
  const SellerLocationResponse({
    required this.seller,
    required this.isOwner,
    required this.location,
    required this.locationVersion,
    this.user,
  });

  final String? seller;
  final String? user;
  final bool isOwner;
  final AOSPlace? location;
  final int locationVersion;

  bool get hasLocation => location?.hasLocation ?? false;

  factory SellerLocationResponse.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['location'];
    final version = _int(json['location_version']) ?? 0;
    return SellerLocationResponse(
      seller: _string(json['seller']),
      user: _string(json['user']),
      isOwner: _bool(json['is_owner']),
      locationVersion: version,
      location: rawLocation is Map
          ? AOSPlace.fromJson({
              ...asJsonMap(rawLocation),
              'location_version': version,
            })
          : null,
    );
  }
}

String? _string(dynamic value) {
  final v = value?.toString().trim();
  if (v == null || v.isEmpty || v == 'null') return null;
  return v;
}

int? _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  final clean = value?.toString().trim().toLowerCase();
  return clean == '1' || clean == 'true' || clean == 'yes';
}
