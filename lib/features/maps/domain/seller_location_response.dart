import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';

class SellerLocationResponse {
  const SellerLocationResponse({
    required this.seller,
    required this.isOwner,
    required this.location,
    this.user,
  });

  final String? seller;
  final String? user;
  final bool isOwner;
  final AOSPlace? location;

  bool get hasLocation => location?.hasLocation ?? false;

  factory SellerLocationResponse.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['location'];
    return SellerLocationResponse(
      seller: _string(json['seller']),
      user: _string(json['user']),
      isOwner: _bool(json['is_owner']),
      location: rawLocation is Map
          ? AOSPlace.fromJson(asJsonMap(rawLocation))
          : null,
    );
  }
}

String? _string(dynamic value) {
  final v = value?.toString().trim();
  if (v == null || v.isEmpty || v == 'null') return null;
  return v;
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  final clean = value?.toString().trim().toLowerCase();
  return clean == '1' || clean == 'true' || clean == 'yes';
}
