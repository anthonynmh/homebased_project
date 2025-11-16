import 'dart:convert';

class BusinessProfile {
  String _id;
  String _updatedAt;
  String _businessName;
  String? _description;
  List<String>? _photoUrls;

  BusinessProfile({
    required String id,
    required String updatedAt,
    required String businessName,
    String? description,
    List<String>? photoUrls,
  }) : _id = id,
       _updatedAt = updatedAt,
       _businessName = businessName,
       _description = description,
       _photoUrls = photoUrls;

  // Getters
  String get id => _id;
  String get updatedAt => _updatedAt;
  String get businessName => _businessName;
  String? get description => _description;
  List<String>? get photoUrls => _photoUrls;

  // Setters (optional, include only if mutation is needed)
  set id(String value) => _id = value;
  set updatedAt(String value) => _updatedAt = value;
  set businessName(String value) => _businessName = value;
  set description(String? value) => _description = value;
  set photoUrls(List<String>? value) => _photoUrls = value;

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as String,
      updatedAt: map['updated_at'] as String,
      businessName: map['business_name'] as String,
      description: map['description'] as String?,
      photoUrls: map['photo_urls'] != null
          ? List<String>.from(map['photo_urls'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'updated_at': _updatedAt,
      'business_name': _businessName,
      'description': _description,
      'photo_urls': _photoUrls,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory BusinessProfile.fromJson(String source) =>
      BusinessProfile.fromMap(jsonDecode(source));

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toMap());
}
