class AdCategory {
  const AdCategory({
    required this.id,
    required this.name,
    this.parentId,
    required this.isService,
  });

  final String id;
  final String name;
  final String? parentId;
  final bool isService;
}

class AdCategoryModel extends AdCategory {
  const AdCategoryModel({
    required super.id,
    required super.name,
    super.parentId,
    required super.isService,
  });

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v == 1;
    if (v is String) {
      final val = v.toLowerCase();
      return val == 'true' || val == '1';
    }
    return false;
  }

  factory AdCategoryModel.fromMap(Map<String, dynamic> map) {
    return AdCategoryModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      parentId: map['parent_id']?.toString(),
      isService: _parseBool(map['is_service']),
    );
  }
}
