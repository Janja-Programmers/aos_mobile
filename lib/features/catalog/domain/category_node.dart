class CategoryNode {
  const CategoryNode({
    required this.id,
    required this.name,
    this.icon,
    this.children = const <CategoryNode>[],
  });

  final String id;
  final String name;
  final String? icon;
  final List<CategoryNode> children;

  factory CategoryNode.fromJson(Map<String, dynamic> json) {
    final kidsRaw = json['children'];
    final kids = <CategoryNode>[];
    if (kidsRaw is List) {
      for (final e in kidsRaw) {
        if (e is Map) {
          kids.add(CategoryNode.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return CategoryNode(
      id: (json['id'] ?? json['name'] ?? '').toString(),
      name:
          (json['category_name'] ??
                  json['title'] ??
                  json['label'] ??
                  json['name'] ??
                  '')
              .toString(),
      icon: (json['icon'] ?? json['image'] ?? '').toString().isEmpty
          ? null
          : (json['icon'] ?? json['image']).toString(),
      children: kids,
    );
  }
}
