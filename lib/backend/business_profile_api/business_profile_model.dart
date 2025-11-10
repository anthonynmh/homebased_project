import 'dart:convert';

class BusinessProfile {
  String id;
  String updatedAt;
  String businessName;
  String? description;
  List<String>? photoUrls;

  BusinessProfile({
    required this.id,
    required this.updatedAt,
    required this.businessName,
    this.description,
    this.photoUrls,
  });

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as String,
      updatedAt: map['updated_at'] as String,
      businessName: map['business_name'] as String,
      description: map['description'] as String?,
      photoUrls: map['photo_urls'] as List<String>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'updated_at': updatedAt,
      'business_name': businessName,
      'description': description,
      'photo_urls': photoUrls,
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }
}
