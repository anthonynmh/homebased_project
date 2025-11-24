import 'dart:convert';

class BusinessProfile {
  String id;
  String updatedAt;
  String? businessName;
  String? description;
  List<String>? photoUrls;
  int? postalCode;

  BusinessProfile({
    required this.id,
    required this.updatedAt,
    this.businessName,
    this.description,
    this.photoUrls,
    this.postalCode,
  });

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as String,
      updatedAt: map['updated_at'] as String,
      businessName: map['business_name'] as String?,
      description: map['description'] as String?,
      photoUrls: map['photo_urls'] != null
          ? List<String>.from(map['photo_urls'])
          : null,
      postalCode: map['postal_code'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'updated_at': updatedAt,
      'business_name': businessName,
      'description': description,
      'photo_urls': photoUrls,
      'postal_code': postalCode,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory BusinessProfile.fromJson(String source) =>
      BusinessProfile.fromMap(jsonDecode(source));

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toMap());
}
