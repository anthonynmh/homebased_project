import 'dart:convert';

class BusinessProfile {
  String name;
  String productType;
  String description;
  List<String>? imagePaths; // list of local file paths or asset paths

  BusinessProfile({
    required this.name,
    required this.productType,
    required this.description,
    this.imagePaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'productType': productType,
      'description': description,
      'imagePaths': imagePaths,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      name: map['name'] ?? '',
      productType: map['productType'] ?? '',
      description: map['description'] ?? '',
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessProfile.fromJson(String source) =>
      BusinessProfile.fromMap(json.decode(source));
}
