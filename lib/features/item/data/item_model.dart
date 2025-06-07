import '../domain/item.dart';

class ItemModel extends Item {
  ItemModel({
    required super.itemCode,
    required super.itemName,
    required super.itemGroup,
    required super.company,
    required super.createdBy,
    required super.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemCode: json['item_code'],
      itemName: json['item_name'],
      itemGroup: json['item_group'],
      company: json['company'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'item_name': itemName,
      'item_group': itemGroup,
      'company': company,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ItemModel.fromDomain(Item item) {
    return ItemModel(
      itemCode: item.itemCode,
      itemName: item.itemName,
      itemGroup: item.itemGroup,
      company: item.company,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
    );
  }
}
