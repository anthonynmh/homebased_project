class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;

  UserProfile({required this.id, required this.name, this.avatarUrl});

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': name, 'avatar_url': avatarUrl};
  }
}
