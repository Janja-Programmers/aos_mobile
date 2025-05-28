import '../domain/item.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.itemName,
    required super.itemGroup,
    required super.company,
    required super.createdBy,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemName: json['item_name'],
      itemGroup: json['item_group'],
      company: json['company'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'item_group': itemGroup,
      'company': company,
      'created_by': createdBy,
    };
  }
}
