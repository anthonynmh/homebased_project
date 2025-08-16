class BusinessProfile {
  final String id;
  final String businessName;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;

  BusinessProfile({
    required this.id, 
    required this.businessName, 
    this.latitude, 
    this.longitude, 
    this.logoUrl,
  });

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as String,
      businessName: map['business_name'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      logoUrl: map['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'business_name': businessName, 'logo_url': logoUrl};
  }
}
