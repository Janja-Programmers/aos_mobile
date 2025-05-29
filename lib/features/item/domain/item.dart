class Item {
  final String itemCode;
  final String itemName;
  final String itemGroup;
  final String company;
  final int createdBy;
  final DateTime createdAt;

  Item({
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.company,
    required this.createdBy,
    required this.createdAt,
  });
}
