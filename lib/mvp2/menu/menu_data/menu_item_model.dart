import 'dart:convert';

class MenuItem {
  String userId;
  String name;
  String createdAt;
  String updatedAt;
  String? description;
  int? quantity;
  double? price;

  MenuItem({
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.quantity,
    this.price,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'item_name': name,
      'item_description': description,
      'item_quantity': quantity,
      'item_price': price,
    };

    return map;
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      userId: map['user_id'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      name: map['item_name'] ?? '',
      description: map['item_description'] ?? '',
      quantity: map['item_quantity']?.toInt() ?? 0,
      price: map['item_price']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory MenuItem.fromJson(String source) =>
      MenuItem.fromMap(json.decode(source));

  MenuItem copyWith({
    required String userId,
    required String createdAt,
    required String updatedAt,
    required String name,
    String? description,
    int? quantity,
    double? price,
  }) {
    return MenuItem(
      userId: this.userId,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      name: this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toMap());
}
