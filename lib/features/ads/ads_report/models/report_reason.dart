import 'package:africaonlinestores/core/utils/json_utils.dart';

class ReportReason {
  final String id;
  final String title;
  final String? iconKey;

  const ReportReason({required this.id, required this.title, this.iconKey});

  factory ReportReason.fromJson(Map<String, dynamic> json) {
    return ReportReason(
      id: asString(json['id']),
      title: asString(json['title']),
      iconKey: asNullableString(json['icon_key']),
    );
  }
}
