import 'dart:convert';

class StorefrontSchedule {
  String storefrontId;
  DateTime openDay;
  String createdAt;
  String updatedAt;

  StorefrontSchedule({
    required this.storefrontId,
    required this.openDay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StorefrontSchedule.fromMap(Map<String, dynamic> map) {
    return StorefrontSchedule(
      storefrontId: map['storefront_id'] as String,
      openDay: map['open_day'] as DateTime,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storefront_id': storefrontId,
      'open_day': openDay,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory StorefrontSchedule.fromJson(String source) =>
      StorefrontSchedule.fromMap(jsonDecode(source));

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toMap());
}
