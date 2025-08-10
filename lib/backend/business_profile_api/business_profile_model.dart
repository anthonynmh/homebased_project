class BusinessProfile {
  final int id;
  final DateTime? createdAt;
  final String name;
  final String? description;
  final String? sector;
  final String? photosUrl;
  final String auth0Sub;
  final String? location;

  BusinessProfile({
    required this.id,
    this.createdAt,
    required this.name,
    this.description,
    this.sector,
    this.photosUrl,
    required this.auth0Sub,
    this.location,
  });

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      name: (map['name'] ?? '') as String,
      description: map['description'] as String?,
      sector: map['sector'] as String?,
      photosUrl: map['photos_url'] as String?,
      auth0Sub: map['auth0_sub'] as String,
      location: map['location'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'name': name,
      'description': description,
      'sector': sector,
      'photos_url': photosUrl,
      'auth0_sub': auth0Sub,
      'location': location,
    };
  }

  // Create a copyWith method to easily update auth0Sub
  BusinessProfile copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
    String? sector,
    String? photosUrl,
    String? auth0Sub,
    String? location,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      photosUrl: photosUrl ?? this.photosUrl,
      auth0Sub: auth0Sub ?? this.auth0Sub,
      location: location ?? this.location,
    );
  }
}
