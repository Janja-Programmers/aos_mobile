class AOSAdImage {
  const AOSAdImage({
    required this.image,
    required this.fileId,
    required this.isPrimary,
    required this.sortOrder,
  });

  final String image;
  final String fileId;
  final bool isPrimary;
  final int sortOrder;

  factory AOSAdImage.fromJson(dynamic json) {
    if (json is Map) {
      return AOSAdImage(
        image: (json['image'] ?? '').toString(),
        fileId: (json['file_id'] ?? json['file'] ?? '').toString(),
        isPrimary:
            json['is_primary'] == 1 ||
            json['is_primary'] == true ||
            json['is_primary']?.toString() == '1',
        sortOrder: int.tryParse((json['sort_order'] ?? 0).toString()) ?? 0,
      );
    }

    return AOSAdImage(
      image: json?.toString() ?? '',
      fileId: '',
      isPrimary: false,
      sortOrder: 0,
    );
  }
}
