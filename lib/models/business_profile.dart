import 'dart:convert';

class BusinessProfile {
  String name;
  String productType;
  String description;
  double? latitude;
  double? longitude;
  List<String>? imagePaths; // list of local file paths or asset paths

  BusinessProfile({
    required this.name,
    required this.productType,
    required this.description,
    this.imagePaths,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'productType': productType,
      'description': description,
      'imagePaths': imagePaths,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      name: map['name'] ?? '',
      productType: map['productType'] ?? '',
      description: map['description'] ?? '',
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessProfile.fromJson(String source) =>
      BusinessProfile.fromMap(json.decode(source));

  BusinessProfile copyWith({
    String? name,
    String? productType,
    String? description,
    List<String>? imagePaths,
    double? latitude,
    double? longitude,
  }) {
    return BusinessProfile(
      name: name ?? this.name,
      productType: productType ?? this.productType,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
