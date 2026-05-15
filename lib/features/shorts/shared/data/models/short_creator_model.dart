class ShortCreatorModel {
  final String user;
  final String displayName;
  final String? avatar;
  final bool isVerified;
  final ShortCreatorSellerModel? seller;

  const ShortCreatorModel({
    required this.user,
    required this.displayName,
    this.avatar,
    required this.isVerified,
    this.seller,
  });

  factory ShortCreatorModel.empty() {
    return const ShortCreatorModel(
      user: '',
      displayName: '',
      avatar: null,
      isVerified: false,
      seller: null,
    );
  }

  factory ShortCreatorModel.fromJson(Map<String, dynamic> json) {
    return ShortCreatorModel(
      user: json['user']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      isVerified: _toBool(json['is_verified']),
      seller: _parseSeller(json['seller']),
    );
  }

  static ShortCreatorSellerModel? _parseSeller(dynamic value) {
    if (value is! Map<String, dynamic>) return null;

    final id = value['id']?.toString() ?? '';

    if (id.isEmpty) return null;

    return ShortCreatorSellerModel(id: id);
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = value?.toString().trim().toLowerCase();

    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}

class ShortCreatorSellerModel {
  final String id;

  const ShortCreatorSellerModel({required this.id});
}
