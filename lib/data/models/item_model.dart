import 'dart:convert';

/// Convert JSON string to List<ItemModel>
List<ItemModel> itemListFromJson(dynamic data) {
  // Expecting 'data' to be a List<dynamic>
  if (data is List) {
    return List<ItemModel>.from(data.map((x) => ItemModel.fromJson(x)));
  }

  throw const FormatException(
    'Invalid data format: expected a List<dynamic> of JSON objects',
  );
}

/// Convert List<ItemModel> to JSON string
String itemListToJson(List<ItemModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// Enum for item status
enum ItemStatus { inStock, lowStock, outOfStock }

extension ItemStatusExtension on ItemStatus {
  String get value {
    switch (this) {
      case ItemStatus.inStock:
        return 'In Stock';
      case ItemStatus.lowStock:
        return 'Low Stock';
      case ItemStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  static ItemStatus fromValue(String value) {
    switch (value) {
      case 'In Stock':
        return ItemStatus.inStock;
      case 'Low Stock':
        return ItemStatus.lowStock;
      default:
        return ItemStatus.outOfStock;
    }
  }
}

/// Model class similar to TypeORM Entity
class ItemModel {
  final int id;
  final String itemName;
  final String sku;
  final String? category;
  final String? description;
  final int quantity;
  final double price;
  final ItemStatus status;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.sku,
    this.category,
    this.description,
    this.quantity = 0,
    this.price = 0.0,
    this.status = ItemStatus.outOfStock,
  });

  /// Factory to create object from JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json["id"],
    itemName: json["item_name"],
    sku: json["sku"],
    category: json["category"],
    description: json["description"],
    quantity: json["quantity"] ?? 0,
    price: double.tryParse(json["price"].toString()) ?? 0.0,
    status: ItemStatusExtension.fromValue(json["status"]),
  );

  /// Convert object to JSON
  Map<String, dynamic> toJson() => {
    "id": id,
    "item_name": itemName,
    "sku": sku,
    "category": category,
    "description": description,
    "quantity": quantity,
    "price": price,
    "status": status.value,
  };
}
