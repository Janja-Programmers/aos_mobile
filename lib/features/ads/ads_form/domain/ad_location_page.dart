import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';

class AdLocation {
  const AdLocation({
    required this.id,
    required this.name,
    required this.country,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String country;
  final int sortOrder;

  factory AdLocation.fromJson(Map<String, dynamic> json) {
    return AdLocation(
      id: asString(json['id'] ?? json['name']).trim(),
      name: asString(
        json['label'] ??
            json['location'] ??
            json['city'] ??
            json['name'] ??
            json['title'],
      ).trim(),
      country: asString(json['country']).trim(),
      sortOrder: asInt(json['sort_order']),
    );
  }
}

class AdLocationPage {
  const AdLocationPage({
    required this.items,
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<AdLocation> items;
  final int limit;
  final int offset;
  final bool hasMore;
  final int? nextOffset;
}

abstract interface class AdLocationRepository {
  Future<Either<Failure, AdLocationPage>> getLocations({
    String? query,
    int limit = 20,
    int offset = 0,
  });
}
