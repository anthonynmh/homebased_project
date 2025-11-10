import 'dart:convert';

class BusinessProfile {
  String name;
  String description;
  List<String>? imagePaths; // list of local file paths or asset paths

  BusinessProfile({
    required this.name,
    required this.description,
    this.imagePaths,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'imagePaths': imagePaths};
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
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
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}
