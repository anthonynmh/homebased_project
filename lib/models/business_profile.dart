import 'dart:convert';

class BusinessProfile {
  String name;
  String productType;
  String address;
  List<String>? imagePaths; // list of local file paths or asset paths

  BusinessProfile({
    required this.name,
    required this.productType,
    required this.address,
    this.imagePaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'productType': productType,
      'address': address,
      'imagePaths': imagePaths,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      name: map['name'] ?? '',
      productType: map['productType'] ?? '',
      address: map['address'] ?? '',
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessProfile.fromJson(String source) =>
      BusinessProfile.fromMap(json.decode(source));
}
