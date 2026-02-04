class AOSAdListItem {
  const AOSAdListItem({
    required this.id,
    required this.title,
    required this.country,
    required this.locationName,
    required this.categoryName,
    required this.currency,
    required this.priceType,
    required this.price,
    required this.priceUnit,
    required this.coverImage,
  });

  final String id;
  final String title;
  final String country;
  final String locationName;
  final String categoryName;
  final String currency;
  final String priceType;
  final double? price;
  final String priceUnit;
  final String coverImage;

  factory AOSAdListItem.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] is List)
        ? (json['images'] as List)
        : const [];
    String cover = (json['primary_image'] ?? json['image'] ?? '').toString();
    if (cover.isEmpty && images.isNotEmpty) {
      final first = images.first;
      if (first is Map) {
        cover = (first['image'] ?? '').toString();
      }
    }

    double? price;
    final rawPrice = json['price'];
    if (rawPrice != null && rawPrice.toString().trim().isNotEmpty) {
      price = double.tryParse(rawPrice.toString());
    }

    return AOSAdListItem(
      id: (json['id'] ?? json['name'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      locationName: (json['location_name'] ?? json['location'] ?? '')
          .toString(),
      categoryName: (json['category_name'] ?? json['category'] ?? '')
          .toString(),
      currency: (json['currency'] ?? '').toString(),
      priceType: (json['price_type'] ?? '').toString(),
      price: price,
      priceUnit: (json['price_unit'] ?? '').toString(),
      coverImage: cover,
    );
  }
}

class AOSAdDetails {
  const AOSAdDetails({
    required this.id,
    required this.title,
    required this.status,
    required this.country,
    required this.locationName,
    required this.categoryName,
    required this.description,
    required this.currency,
    required this.priceType,
    required this.price,
    required this.priceUnit,
    required this.images,
    required this.video,
    required this.specs,
  });

  final String id;
  final String title;
  final String status;
  final String country;
  final String locationName;
  final String categoryName;
  final String description;
  final String currency;
  final String priceType;
  final double? price;
  final String priceUnit;
  final List<String> images;
  final String? video;
  final List<Map<String, String>> specs;

  factory AOSAdDetails.fromJson(Map<String, dynamic> json) {
    final images = <String>[];
    if (json['images'] is List) {
      for (final e in (json['images'] as List)) {
        if (e is Map) {
          final u = (e['image'] ?? '').toString();
          if (u.isNotEmpty) images.add(u);
        } else {
          final u = e.toString();
          if (u.isNotEmpty) images.add(u);
        }
      }
    }

    double? price;
    final rawPrice = json['price'];
    if (rawPrice != null && rawPrice.toString().trim().isNotEmpty) {
      price = double.tryParse(rawPrice.toString());
    }

    final specs = <Map<String, String>>[];
    // backend may return details/specs as list
    final rawSpecs = json['specs'] ?? json['details'] ?? json['attributes'];
    if (rawSpecs is List) {
      for (final e in rawSpecs) {
        if (e is Map) {
          final k = (e['label'] ?? e['name'] ?? e['key'] ?? '').toString();
          final v =
              (e['value'] ??
                      e['value_text'] ??
                      e['value_number'] ??
                      e['value_date'] ??
                      '')
                  .toString();
          if (k.isNotEmpty && v.isNotEmpty) {
            specs.add({'label': k, 'value': v});
          }
        }
      }
    }

    return AOSAdDetails(
      id: (json['id'] ?? json['name'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      locationName: (json['location_name'] ?? json['location'] ?? '')
          .toString(),
      categoryName: (json['category_name'] ?? json['category'] ?? '')
          .toString(),
      description: (json['description'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      priceType: (json['price_type'] ?? '').toString(),
      price: price,
      priceUnit: (json['price_unit'] ?? '').toString(),
      images: images,
      video: (json['video'] ?? '').toString().trim().isEmpty
          ? null
          : (json['video'] ?? '').toString(),
      specs: specs,
    );
  }
}
