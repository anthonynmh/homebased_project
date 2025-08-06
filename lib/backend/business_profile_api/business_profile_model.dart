class BusinessProfile {
  final String id;
  final String businessName;
  final String? logoUrl;

  BusinessProfile({required this.id, required this.businessName, this.logoUrl});

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as String,
      businessName: map['business_name'] as String,
      logoUrl: map['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'business_name': businessName, 'logo_url': logoUrl};
  }
}
