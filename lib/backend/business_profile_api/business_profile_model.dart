import 'dart:convert';

class BusinessProfile {
  final String? id;
  final String? updatedAt;
  final String? businessName;
  final String? description;
  final String? sector;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final List<dynamic>? photoUrls;

  BusinessProfile({
    this.id,
    this.updatedAt,
    this.businessName,
    this.description,
    this.sector,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.photoUrls,
  });

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as String,
      updatedAt: map['updated_at'] as String?,
      businessName: map['business_name'] as String?,
      description: map['description'] as String?,
      sector: map['sector'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      logoUrl: map['logo_url'] as String?,
      photoUrls: map['photo_urls'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'updated_at': updatedAt,
      'business_name': businessName,
      'description': description,
      'sector': sector,
      'longitude': longitude,
      'latitude': latitude,
      'logo_url': logoUrl,
      'photo_urls': photoUrls,
    };
  }

  BusinessProfile copyWith({
    String? id,
    String? updatedAt,
    String? businessName,
    String? description,
    String? sector,
    double? latitude,
    double? longitude,
    String? logoUrl,
    List<String>? photoUrls,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }
}
