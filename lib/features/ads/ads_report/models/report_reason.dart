class ReportReason {
  final String id;
  final String title;
  final String? iconKey;

  const ReportReason({required this.id, required this.title, this.iconKey});

  factory ReportReason.fromJson(Map<String, dynamic> json) {
    return ReportReason(
      id: json['id'],
      title: json['title'],
      iconKey: json['icon_key'],
    );
  }
}
