class UserProfile {
  final int id;
  final String auth0Sub;
  final String name;
  final String email;
  final String? profilePhotoUrl;

  UserProfile({
    required this.id,
    required this.auth0Sub,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int,
      auth0Sub: map['auth0_sub'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      profilePhotoUrl: map['profile_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auth0_sub': auth0Sub,
      'name': name,
      'email': email,
      'profile_photo_url': profilePhotoUrl,
    };
  }
}
